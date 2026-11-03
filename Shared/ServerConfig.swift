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
    
    public var countryFlag: String {
        if name.contains("⚡") || name.contains("Автовыбор") {
            return "⚡"
        } else if countryCode == "RU" || isLTEBypass {
            return "🇷🇺"
        } else if countryCode == "NL" {
            return "🇳🇱"
        } else if countryCode == "FI" {
            return "🇫🇮"
        } else {
            return "🇩🇪"
        }
    }
    
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
    
    /// Parses an array of Happ / RemnaWave JSON objects
    public static func parseFromHappJsonArray(_ jsonArray: [[String: Any]]) -> [ServerConfig] {
        var result: [ServerConfig] = []
        for dict in jsonArray {
            if let srv = parseHappObject(dict) {
                result.append(srv)
            }
        }
        return result
    }
    
    public static func parseHappObject(_ dict: [String: Any]) -> ServerConfig? {
        let remarks = dict["remarks"] as? String ?? dict["name"] as? String ?? "Сервер"
        guard let outbounds = dict["outbounds"] as? [[String: Any]], let ob = outbounds.first else {
            return nil
        }
        
        let protoStr = (ob["protocol"] as? String ?? "vless").lowercased()
        let streamSettings = ob["streamSettings"] as? [String: Any] ?? [:]
        let netStr = (streamSettings["network"] as? String ?? "tcp").lowercased()
        let secStr = (streamSettings["security"] as? String ?? "none").lowercased()
        
        var host = ""
        var port = 443
        var uuid = ""
        var flow: String? = nil
        
        if protoStr == "vless" || protoStr == "vmess" {
            let settings = ob["settings"] as? [String: Any] ?? [:]
            if let vnext = settings["vnext"] as? [[String: Any]], let firstVnext = vnext.first {
                host = firstVnext["address"] as? String ?? ""
                port = firstVnext["port"] as? Int ?? 443
                if let users = firstVnext["users"] as? [[String: Any]], let firstUser = users.first {
                    uuid = firstUser["id"] as? String ?? ""
                    flow = firstUser["flow"] as? String
                }
            }
        } else if protoStr == "hysteria" || protoStr == "hysteria2" {
            let settings = ob["settings"] as? [String: Any] ?? [:]
            host = settings["server"] as? String ?? settings["address"] as? String ?? ""
            port = settings["port"] as? Int ?? 443
            let hysteriaSettings = streamSettings["hysteriaSettings"] as? [String: Any] ?? [:]
            uuid = hysteriaSettings["auth"] as? String ?? settings["auth"] as? String ?? ""
        }
        
        guard !host.isEmpty else { return nil }
        
        // Transport
        let transport: TransportType
        if netStr == "xhttp" || netStr == "splithttp" {
            transport = .splithttp
        } else if netStr == "grpc" {
            transport = .grpc
        } else if netStr == "ws" {
            transport = .ws
        } else {
            transport = .tcp
        }
        
        // Security
        let security: SecurityType
        if secStr == "reality" {
            security = .reality
        } else if secStr == "tls" {
            security = .tls
        } else {
            security = .none
        }
        
        // Reality / TLS details
        var sni: String? = nil
        var pbk: String? = nil
        var sid: String? = nil
        var fp: String? = "chrome"
        
        if security == .reality {
            let realitySettings = streamSettings["realitySettings"] as? [String: Any] ?? [:]
            sni = realitySettings["serverName"] as? String
            pbk = realitySettings["publicKey"] as? String
            sid = realitySettings["shortId"] as? String
            fp = realitySettings["fingerprint"] as? String ?? "chrome"
        } else if security == .tls {
            let tlsSettings = streamSettings["tlsSettings"] as? [String: Any] ?? [:]
            sni = tlsSettings["serverName"] as? String
        }
        
        // Path and Host Header
        var path: String? = nil
        var hostHeader: String? = nil
        if transport == .splithttp {
            let xhttpSettings = streamSettings["xhttpSettings"] as? [String: Any] ?? [:]
            path = xhttpSettings["path"] as? String
            hostHeader = xhttpSettings["host"] as? String
        } else if transport == .ws {
            let wsSettings = streamSettings["wsSettings"] as? [String: Any] ?? [:]
            path = wsSettings["path"] as? String
            if let headers = wsSettings["headers"] as? [String: String] {
                hostHeader = headers["Host"]
            }
        } else if transport == .grpc {
            let grpcSettings = streamSettings["grpcSettings"] as? [String: Any] ?? [:]
            path = grpcSettings["serviceName"] as? String
        }
        
        let isForeign = remarks.contains("Германия") ||
                        remarks.contains("Нидерланды") ||
                        remarks.contains("Финляндия") ||
                        remarks.contains("DE") ||
                        remarks.contains("NL") ||
                        remarks.contains("FI") ||
                        remarks.contains("🇩🇪") ||
                        remarks.contains("🇳🇱") ||
                        remarks.contains("🇫🇮")
        
        let isLTE = !isForeign && (
            remarks.contains("LTE") ||
            remarks.contains("CDN") ||
            remarks.contains("Selectel") ||
            remarks.contains("Яндекс") ||
            remarks.contains("Yandex") ||
            remarks.contains("🇷🇺")
        )
        
        var country = "DE"
        if remarks.contains("🇷🇺") || remarks.contains("RU") || remarks.contains("Россия") || isLTE {
            country = "RU"
        } else if remarks.contains("🇩🇪") || remarks.contains("DE") || remarks.contains("Германия") {
            country = "DE"
        } else if remarks.contains("🇳🇱") || remarks.contains("NL") || remarks.contains("Нидерланды") {
            country = "NL"
        } else if remarks.contains("🇫🇮") || remarks.contains("FI") || remarks.contains("Финляндия") {
            country = "FI"
        }
        
        var proto: ServerProtocol = .vless
        if protoStr == "hysteria" || protoStr == "hysteria2" {
            proto = .hysteria2
        } else if protoStr == "vmess" {
            proto = .vmess
        } else if protoStr == "trojan" {
            proto = .trojan
        }
        
        return ServerConfig(
            name: remarks,
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
        
        let isForeign = name.contains("Германия") ||
                        name.contains("Нидерланды") ||
                        name.contains("Финляндия") ||
                        name.contains("DE") ||
                        name.contains("NL") ||
                        name.contains("FI") ||
                        name.contains("🇩🇪") ||
                        name.contains("🇳🇱") ||
                        name.contains("🇫🇮")
        
        let isLTE = !isForeign && (
            name.contains("LTE") ||
            name.contains("CDN") ||
            name.contains("Selectel") ||
            name.contains("Yandex") ||
            name.contains("Яндекс") ||
            name.contains("🇷🇺")
        )
        
        var proto: ServerProtocol = .vless
        if scheme == "hysteria2" || scheme == "hy2" {
            proto = .hysteria2
        } else if scheme == "vmess" {
            proto = .vmess
        } else if scheme == "trojan" {
            proto = .trojan
        }
        
        var country = "DE"
        if name.contains("🇷🇺") || name.contains("RU") || name.contains("Россия") || isLTE {
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
