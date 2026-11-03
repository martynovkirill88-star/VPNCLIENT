//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  NEPacketTunnelProvider implementation powering the system VPN tunnel.
//

import NetworkExtension
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private var isRunning = false
    private var activeConfigJson: String = ""
    private var startTime: Date?
    private var currentServerName: String = "Auto Node"
    private var currentServerTag: String = "proxy"
    
    // Traffic metrics
    private var totalInBytes: UInt64 = 0
    private var totalOutBytes: UInt64 = 0
    private var lastSpeedCheckDate: Date = Date()
    private var lastInBytes: UInt64 = 0
    private var lastOutBytes: UInt64 = 0
    private var currentDownBps: Double = 0
    private var currentUpBps: Double = 0
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let configJson = (options?["configJson"] as? String) ?? "{}"
        self.activeConfigJson = configJson
        if let name = options?["serverName"] as? String {
            self.currentServerName = name
        }
        
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "172.19.0.2")
        
        // IPv4 configuration
        let ipv4Settings = NEIPv4Settings(addresses: ["172.19.0.1"], subnetMasks: ["255.255.255.252"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = [
            NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
            NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0"),
            NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0")
        ]
        settings.ipv4Settings = ipv4Settings
        
        // DNS configuration
        let dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8", "77.88.8.8"])
        dnsSettings.matchDomains = [""]
        settings.dnsSettings = dnsSettings
        
        // MTU
        settings.mtu = 9000
        
        setTunnelNetworkSettings(settings) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completionHandler(error)
                return
            }
            
            self.isRunning = true
            self.startTime = Date()
            
            // Start Tunnel Core engine
            CoreTunnelBridge.shared.startEngine(configJson: configJson) { started in
                if started {
                    self.startPacketLoop()
                    completionHandler(nil)
                } else {
                    completionHandler(NSError(domain: "PacketTunnel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize VPN core engine"]))
                }
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        isRunning = false
        CoreTunnelBridge.shared.stopEngine()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        guard let request = try? JSONDecoder().decode(IPCRequest.self, from: messageData) else {
            completionHandler?(nil)
            return
        }
        
        switch request.command {
        case .getStats:
            updateSpeedCalculations()
            let uptime = startTime.map { Date().timeIntervalSince($0) } ?? 0
            let stats = IPCTrafficStats(
                uploadSpeedBps: currentUpBps,
                downloadSpeedBps: currentDownBps,
                totalUploadedBytes: totalOutBytes,
                totalDownloadedBytes: totalInBytes,
                uptimeSeconds: uptime,
                activeServerTag: currentServerTag,
                activeServerName: currentServerName
            )
            let response = IPCResponse(success: true, stats: stats)
            let responseData = try? JSONEncoder().encode(response)
            completionHandler?(responseData)
            
        case .switchServer:
            if let payload = request.payload,
               let newServer = try? JSONDecoder().decode(ServerConfig.self, from: payload) {
                self.currentServerName = newServer.name
                CoreTunnelBridge.shared.switchServer(to: newServer)
                let response = IPCResponse(success: true, message: "Switched to \(newServer.name)")
                completionHandler?(try? JSONEncoder().encode(response))
            } else {
                completionHandler?(nil)
            }
            
        case .reloadConfig:
            if let payload = request.payload,
               let newConfigStr = String(data: payload, encoding: .utf8) {
                CoreTunnelBridge.shared.reloadConfig(newConfigStr)
                let response = IPCResponse(success: true, message: "Config reloaded")
                completionHandler?(try? JSONEncoder().encode(response))
            } else {
                completionHandler?(nil)
            }
            
        case .ping:
            let response = IPCResponse(success: true, message: "pong")
            completionHandler?(try? JSONEncoder().encode(response))
            
        case .stopTunnel:
            cancelTunnelWithError(nil)
            let response = IPCResponse(success: true)
            completionHandler?(try? JSONEncoder().encode(response))
        }
    }
    
    private func startPacketLoop() {
        guard isRunning else { return }
        
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self, self.isRunning else { return }
            
            for (idx, packet) in packets.enumerated() {
                self.totalOutBytes += UInt64(packet.count)
                let proto = protocols[idx]
                
                // Route packet through engine
                CoreTunnelBridge.shared.processOutgoingPacket(packet, protocolNumber: proto) { responsePackets, respProtocols in
                    if !responsePackets.isEmpty {
                        for p in responsePackets {
                            self.totalInBytes += UInt64(p.count)
                        }
                        self.packetFlow.writePackets(responsePackets, withProtocols: respProtocols)
                    }
                }
            }
            
            // Loop next batch
            self.startPacketLoop()
        }
    }
    
    private func updateSpeedCalculations() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastSpeedCheckDate)
        guard elapsed >= 0.5 else { return }
        
        let deltaIn = totalInBytes >= lastInBytes ? totalInBytes - lastInBytes : 0
        let deltaOut = totalOutBytes >= lastOutBytes ? totalOutBytes - lastOutBytes : 0
        
        currentDownBps = Double(deltaIn) / elapsed
        currentUpBps = Double(deltaOut) / elapsed
        
        lastInBytes = totalInBytes
        lastOutBytes = totalOutBytes
        lastSpeedCheckDate = now
    }
}
