//
//  NetworkMonitor.swift
//  VPNCLIENT
//
//  Real-time network interface monitor detecting Cellular vs Wi-Fi transitions.
//

import Foundation
import Network
import Combine

public final class NetworkMonitor: ObservableObject {
    public static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.vpnclient.networkmonitor", qos: .utility)
    
    @Published public private(set) var currentType: NetworkType = .unknown
    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var isCellular: Bool = false
    @Published public private(set) var isWiFi: Bool = false
    @Published public private(set) var interfaceName: String = ""
    
    private var lastReportedType: NetworkType?
    
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let connected = (path.status == .satisfied)
            var detectedType: NetworkType = .unknown
            
            if !connected {
                detectedType = .disconnected
            } else if path.usesInterfaceType(.wifi) {
                detectedType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                detectedType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                detectedType = .ethernet
            } else {
                detectedType = .unknown
            }
            
            let ifaceName = path.availableInterfaces.first?.name ?? "en0"
            
            DispatchQueue.main.async {
                let typeChanged = (self.lastReportedType != detectedType)
                self.isConnected = connected
                self.currentType = detectedType
                self.isCellular = (detectedType == .cellular)
                self.isWiFi = (detectedType == .wifi)
                self.interfaceName = ifaceName
                
                if typeChanged {
                    self.lastReportedType = detectedType
                    NotificationCenter.default.post(
                        name: SharedConstants.networkChangedNotification,
                        object: detectedType
                    )
                }
            }
        }
        monitor.start(queue: queue)
    }
}
