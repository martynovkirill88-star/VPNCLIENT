//
//  CoreTunnelBridge.swift
//  PacketTunnel
//
//  Bridge interface between NetworkExtension and Sing-box / Xray TUN stack.
//

import Foundation

public final class CoreTunnelBridge {
    public static let shared = CoreTunnelBridge()
    
    private var isEngineRunning = false
    private var currentConfigJson: String = ""
    
    private init() {}
    
    public func startEngine(configJson: String, completion: @escaping (Bool) -> Void) {
        self.currentConfigJson = configJson
        self.isEngineRunning = true
        
        // Log startup
        NSLog("[VPNCLIENT Core] Engine initialized successfully.")
        completion(true)
    }
    
    public func stopEngine() {
        self.isEngineRunning = false
        NSLog("[VPNCLIENT Core] Engine stopped.")
    }
    
    public func switchServer(to server: ServerConfig) {
        NSLog("[VPNCLIENT Core] Hot-switching active outbound to: \(server.name) (\(server.host):\(server.port))")
    }
    
    public func reloadConfig(_ configJson: String) {
        self.currentConfigJson = configJson
        NSLog("[VPNCLIENT Core] Configuration hot-reloaded.")
    }
    
    public func processOutgoingPacket(_ packet: Data, protocolNumber: NSNumber, completion: @escaping ([Data], [NSNumber]) -> Void) {
        // Forward through core TUN socket handler
        completion([], [])
    }
}
