//
//  ServerConfig.swift
//  VPNCLIENT
//
//  Data model representing an Xray / Sing-box server configuration.
//

import Foundation

public enum ServerProtocol: String, Codable, CaseIterable {
    case vless = "vless"
    case vmess = "vmess"
    case trojan = "trojan"
    case hysteria2 = "hysteria2"
    case shadowsocks = "shadowsocks"
    
    public var displayName: String {
        switch self {
        case .vless: return "VLESS"
        case .vmess: return "VMess"
        case .trojan: return "Trojan"
        case .hysteria2: return "Hysteria 2"
        case .shadowsocks: return "Shadowsocks"
        }
    }
    
    public var singboxType: String {
        switch self {
        case .vless: return "vless"
        case .vmess: return "vmess"
        case .trojan: return "trojan"
        case .hysteria2: return "hysteria2"
        case .shadowsocks: return "shadowsocks"
        }
    }
}

public enum TransportType: String, Codable, CaseIterable {
    case splithttp = "splithttp"
    case grpc = "grpc"
    case ws = "ws"
    case tcp = "tcp"
    case h2 = "h2"
    
    public var displayName: String {
        switch self {
        case .splithttp: return "SplitHTTP (XHTTP)"
        case .grpc: return "gRPC"
        case .ws: return "WebSocket"
        case .tcp: return "TCP"
        case .h2: return "HTTP/2"
        }
    }
}

public enum SecurityType: String, Codable, CaseIterable {
    case reality = "reality"
    case tls = "tls"
    case none = "none"
    
    public var displayName: String {
        switch self {
        case .reality: return "Reality"
        case .tls: return "TLS"
        case .none: return "Прямой (None)"
        }
    }
}

public struct ServerConfig: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var host: String
    public var port: Int
    public var protocolType: ServerProtocol
    public var uuid: String
    public var flow: String?
    public var transportType: TransportType
    public var securityType: SecurityType
    public var sni: String?
    public var fingerprint: String?
    public var publicKey: String?
    public var shortId: String?
    public var path: String?
    public var hostHeader: String?
    
    // Smart Routing Tags
    public var isLTEBypass: Bool
    public var countryCode: String
    public var pingMs: Int?
    public var isFavorite: Bool
    public var dateAdded: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        host: String,
        port: Int,
        protocolType: ServerProtocol = .vless,
        uuid: String = "",
        flow: String? = nil,
        transportType: TransportType = .tcp,
        securityType: SecurityType = .none,
        sni: String? = nil,
        fingerprint: String? = "chrome",
        publicKey: String? = nil,
        shortId: String? = nil,
        path: String? = nil,
        hostHeader: String? = nil,
        isLTEBypass: Bool = false,
        countryCode: String = "DE",
        pingMs: Int? = nil,
        isFavorite: Bool = false,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.protocolType = protocolType
        self.uuid = uuid
        self.flow = flow
        self.transportType = transportType
        self.securityType = securityType
        self.sni = sni
        self.fingerprint = fingerprint
        self.publicKey = publicKey
        self.shortId = shortId
        self.path = path
        self.hostHeader = hostHeader
        self.isLTEBypass = isLTEBypass
        self.countryCode = countryCode
        self.pingMs = pingMs
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
    }
    
    /// Parses vless:// or hysteria2:// or vmess:// URI
    public static func parse(uri: String) -> ServerConfig? {
        let trimmed = uri.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else { return nil }
        
        let scheme = url.scheme?.lowercased() ?? ""
        guard let host = url.host, let port = url.port else { return nil }
        
        let name = url.fragment?.removingPercentEncoding ?? "Сервер \(host)"
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        var queryMap: [String: String] = [:]
        for item in queryItems {
            queryMap[item.name.lowercased()] = item.value
        }
        
        let uuid = url.user ?? ""
        let securityStr = queryMap["security"]?.lowercased() ?? "none"
        let security: SecurityType
        if securityStr == "reality" { security = .reality }
        else if securityStr == "tls" { security = .tls }
        else { security = .none }
        
        let typeStr = queryMap["type"]?.lowercased() ?? "tcp"
        let transport: TransportType
        if typeStr.contains("splithttp") || typeStr.contains("xhttp") { transport = .splithttp }
        else if typeStr == "grpc" { transport = .grpc }
        else if typeStr == "ws" { transport = .ws }
        else { transport = .tcp }
        
        let sni = queryMap["sni"] ?? queryMap["host"]
        let pbk = queryMap["pbk"]
        let sid = queryMap["sid"]
        let path = queryMap["path"]
        let hostHeader = queryMap["host"]
        let fp = queryMap["fp"] ?? "chrome"
        let flow = queryMap["flow"]
        
        // Auto-detect LTE CDN bypass server
        let isLTE = name.contains("LTE") ||
                    name.contains("CDN") ||
                    name.contains("Selectel") ||
                    name.contains("Yandex") ||
                    transport == .splithttp
        
        var proto: ServerProtocol = .vless
        if scheme == "hysteria2" || scheme == "hy2" {
            proto = .hysteria2
        } else if scheme == "vmess" {
            proto = .vmess
        } else if scheme == "trojan" {
            proto = .trojan
        }
        
        var country = "DE"
        if name.contains("🇷🇺") || name.contains("RU") || name.contains("Россия") {
            country = "RU"
        } else if name.contains("🇩🇪") || name.contains("DE") || name.contains("Германия") {
            country = "DE"
        } else if name.contains("🇳🇱") || name.contains("NL") || name.contains("Нидерланды") {
            country = "NL"
        } else if name.contains("🇫🇮") || name.contains("FI") || name.contains("Финляндия") {
            country = "FI"
        }
        
        return ServerConfig(
            name: name,
            host: host,
            port: port,
            protocolType: proto,
            uuid: uuid,
            flow: flow,
            transportType: transport,
            securityType: security,
            sni: sni,
            fingerprint: fp,
            publicKey: pbk,
            shortId: sid,
            path: path,
            hostHeader: hostHeader,
            isLTEBypass: isLTE,
            countryCode: country
        )
    }
}
