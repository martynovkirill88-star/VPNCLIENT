//
//  ConfigGenerator.swift
//  VPNCLIENT
//
//  Generates Sing-box / Xray JSON configurations for the TUN interface.
//

import Foundation

public final class ConfigGenerator {
    
    public static func generateSingboxConfig(
        activeServer: ServerConfig,
        allServers: [ServerConfig],
        bypassRu: Bool = true,
        smartRouting: Bool = true,
        isCellular: Bool = false
    ) -> String {
        var outbounds: [[String: Any]] = []
        
        let activeOutbound = createOutbound(from: activeServer, tag: "proxy")
        outbounds.append(activeOutbound)
        
        let lteServers = allServers.filter { $0.isLTEBypass }
        var lteOutboundTags: [String] = []
        for (idx, srv) in lteServers.enumerated() {
            let tag = "lte-node-\(idx + 1)"
            lteOutboundTags.append(tag)
            outbounds.append(createOutbound(from: srv, tag: tag))
        }
        
        if !lteOutboundTags.isEmpty {
            outbounds.append([
                "type": "urltest",
                "tag": "lte-auto",
                "outbounds": lteOutboundTags,
                "url": "http://cp.cloudflare.com/generate_204",
                "interval": "300s",
                "tolerance": 50
            ])
        }
        
        let directServers = allServers.filter { !$0.isLTEBypass }
        var directTags: [String] = []
        for (idx, srv) in directServers.enumerated() {
            let tag = "direct-node-\(idx + 1)"
            directTags.append(tag)
            outbounds.append(createOutbound(from: srv, tag: tag))
        }
        
        if !directTags.isEmpty {
            outbounds.append([
                "type": "urltest",
                "tag": "wifi-least-ping",
                "outbounds": directTags,
                "url": "http://cp.cloudflare.com/generate_204",
                "interval": "180s",
                "tolerance": 20
            ])
        }
        
        outbounds.append(["type": "direct", "tag": "direct"])
        outbounds.append(["type": "block", "tag": "block"])
        outbounds.append(["type": "dns", "tag": "dns-out"])
        
        var rules: [[String: Any]] = [
            ["outbound": "dns-out", "port": [53]],
            ["outbound": "direct", "ip_is_private": true]
        ]
        
        if bypassRu {
            rules.append([
                "outbound": "direct",
                "geosite": ["ru", "yandex", "vk", "mailru", "gov-ru", "category-ru"],
                "geoip": ["ru"]
            ])
        }
        
        let defaultOutboundTag: String
        if smartRouting {
            defaultOutboundTag = isCellular ? (lteOutboundTags.isEmpty ? "proxy" : "lte-auto") : (directTags.isEmpty ? "proxy" : "wifi-least-ping")
        } else {
            defaultOutboundTag = "proxy"
        }
        
        let config: [String: Any] = [
            "log": [
                "level": "warn",
                "timestamp": true
            ],
            "dns": [
                "servers": [
                    [
                        "tag": "dns-remote",
                        "address": "https://1.1.1.1/dns-query",
                        "detour": defaultOutboundTag
                    ],
                    [
                        "tag": "dns-direct",
                        "address": "77.88.8.8",
                        "detour": "direct"
                    ]
                ],
                "rules": [
                    ["outbound": ["any"], "server": "dns-direct"],
                    ["geosite": ["ru"], "server": "dns-direct"]
                ]
            ],
            "inbounds": [
                [
                    "type": "tun",
                    "tag": "tun-in",
                    "interface_name": "utun9",
                    "inet4_address": "172.19.0.1/30",
                    "mtu": 9000,
                    "auto_route": true,
                    "strict_route": true,
                    "stack": "system",
                    "sniff": true,
                    "sniff_override_destination": true
                ]
            ],
            "outbounds": outbounds,
            "route": [
                "rules": rules,
                "final": defaultOutboundTag,
                "auto_detect_interface": true
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            return jsonStr
        }
        return "{}"
    }
    
    private static func createOutbound(from server: ServerConfig, tag: String) -> [String: Any] {
        var outbound: [String: Any] = [
            "type": server.protocolType.singboxType,
            "tag": tag,
            "server": server.host,
            "server_port": server.port,
            "uuid": server.uuid
        ]
        
        if let flow = server.flow, !flow.isEmpty {
            outbound["flow"] = flow
        }
        
        var tlsConfig: [String: Any] = ["enabled": server.securityType != .none]
        if let sni = server.sni, !sni.isEmpty {
            tlsConfig["server_name"] = sni
        }
        if let fp = server.fingerprint, !fp.isEmpty {
            tlsConfig["utls"] = ["enabled": true, "fingerprint": fp]
        }
        if server.securityType == .reality {
            var realityConfig: [String: Any] = ["enabled": true]
            if let pubKey = server.publicKey { realityConfig["public_key"] = pubKey }
            if let shortId = server.shortId { realityConfig["short_id"] = shortId }
            tlsConfig["reality"] = realityConfig
        }
        if server.securityType != .none {
            outbound["tls"] = tlsConfig
        }
        
        switch server.transportType {
        case .splithttp:
            var transport: [String: Any] = [
                "type": "http",
                "path": server.path ?? "/"
            ]
            if let host = server.hostHeader {
                transport["headers"] = ["Host": host]
            }
            outbound["transport"] = transport
        case .grpc:
            outbound["transport"] = [
                "type": "grpc",
                "service_name": server.path ?? ""
            ]
        case .ws:
            outbound["transport"] = [
                "type": "ws",
                "path": server.path ?? "/",
                "headers": server.hostHeader.map { ["Host": $0] } ?? [:]
            ]
        case .tcp, .h2:
            break
        }
        
        return outbound
    }
}
