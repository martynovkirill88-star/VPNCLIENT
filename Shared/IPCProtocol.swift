//
//  IPCProtocol.swift
//  VPNCLIENT
//
//  IPC protocol between Main App and PacketTunnelProvider via sendProviderMessage.
//

import Foundation

public enum IPCCommand: String, Codable {
    case getStats = "get_stats"
    case switchServer = "switch_server"
    case reloadConfig = "reload_config"
    case ping = "ping"
    case stopTunnel = "stop_tunnel"
}

public struct IPCRequest: Codable {
    public let command: IPCCommand
    public let payload: Data?
    
    public init(command: IPCCommand, payload: Data? = nil) {
        self.command = command
        self.payload = payload
    }
}

public struct IPCTrafficStats: Codable {
    public let uploadSpeedBps: Double
    public let downloadSpeedBps: Double
    public let totalUploadedBytes: UInt64
    public let totalDownloadedBytes: UInt64
    public let uptimeSeconds: TimeInterval
    public let activeServerTag: String
    public let activeServerName: String
    
    public init(
        uploadSpeedBps: Double = 0,
        downloadSpeedBps: Double = 0,
        totalUploadedBytes: UInt64 = 0,
        totalDownloadedBytes: UInt64 = 0,
        uptimeSeconds: TimeInterval = 0,
        activeServerTag: String = "",
        activeServerName: String = ""
    ) {
        self.uploadSpeedBps = uploadSpeedBps
        self.downloadSpeedBps = downloadSpeedBps
        self.totalUploadedBytes = totalUploadedBytes
        self.totalDownloadedBytes = totalDownloadedBytes
        self.uptimeSeconds = uptimeSeconds
        self.activeServerTag = activeServerTag
        self.activeServerName = activeServerName
    }
}

public struct IPCResponse: Codable {
    public let success: Bool
    public let message: String?
    public let stats: IPCTrafficStats?
    
    public init(success: Bool, message: String? = nil, stats: IPCTrafficStats? = nil) {
        self.success = success
        self.message = message
        self.stats = stats
    }
}
