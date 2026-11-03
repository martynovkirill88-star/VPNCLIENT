//
//  PingManager.swift
//  VPNCLIENT
//
//  Measures real TCP connection latency for servers concurrently via NWConnection.
//  Preserves exact server order without reshuffling.
//

import Foundation
import Network

public final class PingManager: ObservableObject {
    public static let shared = PingManager()
    
    @Published public var isPinging: Bool = false
    
    private init() {}
    
    /// Tests real TCP connection latency to a single server in milliseconds
    public func ping(server: ServerConfig) async -> Int? {
        guard !server.host.isEmpty, server.port > 0 else { return nil }
        
        return await withCheckedContinuation { continuation in
            let host = NWEndpoint.Host(server.host)
            guard let port = NWEndpoint.Port(rawValue: UInt16(server.port)) else {
                continuation.resume(returning: nil)
                return
            }
            
            let nwParams = NWParameters.tcp
            let connection = NWConnection(host: host, port: port, using: nwParams)
            let queue = DispatchQueue(label: "vpnclient.ping.\(UUID().uuidString)")
            let startTime = DispatchTime.now()
            
            let lock = NSLock()
            var didResume = false
            
            let finish: (Int?) -> Void = { result in
                lock.lock()
                defer { lock.unlock() }
                if !didResume {
                    didResume = true
                    connection.cancel()
                    continuation.resume(returning: result)
                }
            }
            
            // 2.5s Timeout
            queue.asyncAfter(deadline: .now() + 2.5) {
                finish(nil)
            }
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    let elapsed = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
                    let ms = Int(Double(elapsed) / 1_000_000.0)
                    finish(max(1, ms))
                case .failed:
                    finish(nil)
                case .waiting(let error):
                    if case .posix(let code) = error, code == .ETIMEDOUT || code == .ECONNREFUSED {
                        finish(nil)
                    }
                case .cancelled:
                    finish(nil)
                default:
                    break
                }
            }
            
            connection.start(queue: queue)
        }
    }
    
    /// Concurrent batch ping preserving the EXACT original order of servers (no reshuffling!)
    public func pingAll(servers: [ServerConfig]) async -> [ServerConfig] {
        await MainActor.run { self.isPinging = true }
        defer {
            Task { @MainActor in self.isPinging = false }
        }
        
        var orderedResults = servers
        
        await withTaskGroup(of: (Int, Int?).self) { group in
            for (index, server) in servers.enumerated() {
                group.addTask {
                    let latency = await self.ping(server: server)
                    return (index, latency)
                }
            }
            
            for await (index, latency) in group {
                orderedResults[index].pingMs = latency
            }
        }
        
        return orderedResults
    }
    
    /// Finds server with lowest ping (excluding nil / unreachable)
    public func findLowestPingServer(from servers: [ServerConfig]) -> ServerConfig? {
        let pingedOnly = servers.compactMap { s -> (ServerConfig, Int)? in
            guard let ping = s.pingMs, ping > 0 else { return nil }
            return (s, ping)
        }.sorted { $0.1 < $1.1 }
        
        return pingedOnly.first?.0 ?? servers.first
    }
}
