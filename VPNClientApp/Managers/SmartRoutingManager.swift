//
//  SmartRoutingManager.swift
//  VPNCLIENT
//
//  Core intelligent network manager: Automatically routes and connects
//  via LTE 1, 2, 3 on Cellular, and via leastPing low-latency nodes on Wi-Fi.
//

import Foundation
import Combine

public final class SmartRoutingManager: ObservableObject {
    public static let shared = SmartRoutingManager()
    
    @Published public var smartRoutingEnabled: Bool {
        didSet { userDefaults?.set(smartRoutingEnabled, forKey: SharedConstants.smartRoutingEnabledKey) }
    }
    @Published public var autoConnectOnCellular: Bool {
        didSet { userDefaults?.set(autoConnectOnCellular, forKey: SharedConstants.autoConnectOnCellularKey) }
    }
    @Published public var autoConnectOnWiFi: Bool {
        didSet { userDefaults?.set(autoConnectOnWiFi, forKey: SharedConstants.autoConnectOnWiFiKey) }
    }
    @Published public var cellularPolicy: CellularRoutingPolicy {
        didSet { userDefaults?.set(cellularPolicy.rawValue, forKey: SharedConstants.cellularPolicyKey) }
    }
    @Published public var wifiPolicy: WiFiRoutingPolicy {
        didSet { userDefaults?.set(wifiPolicy.rawValue, forKey: SharedConstants.wifiPolicyKey) }
    }
    @Published public var statusMessage: String = "Готов к работе"
    
    private let userDefaults: UserDefaults?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        let defaults = UserDefaults(suiteName: SharedConstants.appGroupId) ?? UserDefaults.standard
        self.userDefaults = defaults
        
        self.smartRoutingEnabled = defaults.object(forKey: SharedConstants.smartRoutingEnabledKey) as? Bool ?? true
        self.autoConnectOnCellular = defaults.object(forKey: SharedConstants.autoConnectOnCellularKey) as? Bool ?? true
        self.autoConnectOnWiFi = defaults.object(forKey: SharedConstants.autoConnectOnWiFiKey) as? Bool ?? true
        
        let cellRaw = defaults.string(forKey: SharedConstants.cellularPolicyKey) ?? CellularRoutingPolicy.forceLTE.rawValue
        self.cellularPolicy = CellularRoutingPolicy(rawValue: cellRaw) ?? .forceLTE
        
        let wifiRaw = defaults.string(forKey: SharedConstants.wifiPolicyKey) ?? WiFiRoutingPolicy.leastPing.rawValue
        self.wifiPolicy = WiFiRoutingPolicy(rawValue: wifiRaw) ?? .leastPing
        
        bindNetworkChanges()
    }
    
    private func bindNetworkChanges() {
        NotificationCenter.default.publisher(for: SharedConstants.networkChangedNotification)
            .compactMap { $0.object as? NetworkType }
            .debounce(for: .milliseconds(600), scheduler: DispatchQueue.main)
            .sink { [weak self] networkType in
                self?.handleNetworkTransition(to: networkType)
            }
            .store(in: &cancellables)
    }
    
    public func handleNetworkTransition(to network: NetworkType) {
        guard smartRoutingEnabled else { return }
        
        switch network {
        case .cellular:
            handleCellularTransition()
        case .wifi:
            handleWiFiTransition()
        case .disconnected:
            statusMessage = "Сеть отключена"
        default:
            break
        }
    }
    
    private func handleCellularTransition() {
        let allServers = SubscriptionManager.shared.servers
        let lteServers = allServers.filter { $0.isLTEBypass }
        
        guard !lteServers.isEmpty else {
            statusMessage = "Внимание: Нет настроенных серверов LTE CDN"
            return
        }
        
        // Select optimal LTE node (LTE 3 / LTE 1 / lowest ping)
        let targetLTE = lteServers.min { ($0.pingMs ?? 999) < ($1.pingMs ?? 999) } ?? lteServers[0]
        statusMessage = "📶 Сотовая сеть: Выбран \(targetLTE.name)"
        
        if VPNManager.shared.state == .connected {
            // Already connected: Hot switch to LTE bypass server
            VPNManager.shared.switchServer(to: targetLTE)
        } else if autoConnectOnCellular {
            // Auto connect when transitioning to cellular
            VPNManager.shared.connect(with: targetLTE)
        }
    }
    
    private func handleWiFiTransition() {
        let allServers = SubscriptionManager.shared.servers
        let directServers = allServers.filter { !$0.isLTEBypass }
        
        // Select server with lowest ping
        Task {
            let pinged = await PingManager.shared.pingAll(servers: directServers.isEmpty ? allServers : directServers)
            let bestServer = pinged.min { ($0.pingMs ?? 999) < ($1.pingMs ?? 999) } ?? allServers.first
            
            await MainActor.run {
                guard let target = bestServer else { return }
                let pingDisplay = target.pingMs != nil ? "\(target.pingMs!) ms" : "OK"
                self.statusMessage = "🛜 Wi-Fi: Выбран самый быстрый \(target.name) (\(pingDisplay))"
                
                if VPNManager.shared.state == .connected {
                    VPNManager.shared.switchServer(to: target)
                } else if self.autoConnectOnWiFi {
                    VPNManager.shared.connect(with: target)
                }
            }
        }
    }
}
