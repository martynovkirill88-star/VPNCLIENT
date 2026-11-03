//
//  SubscriptionManager.swift
//  VPNCLIENT
//
//  Fetches, parses and caches server subscriptions with RemnaWave & Happ compatibility.
//

import Foundation
import Combine

public final class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()
    
    @Published public var servers: [ServerConfig] = []
    @Published public var subscriptionUrl: String
    @Published public var isLoading: Bool = false
    @Published public var lastUpdated: Date?
    @Published public var errorMessage: String?
    
    private let userDefaults: UserDefaults?
    
    private init() {
        self.userDefaults = UserDefaults(suiteName: SharedConstants.appGroupId) ?? UserDefaults.standard
        self.subscriptionUrl = userDefaults?.string(forKey: SharedConstants.subscriptionUrlKey) ?? SharedConstants.defaultSubscriptionUrl
        loadCachedServers()
        
        // If empty, populate with default initial servers
        if servers.isEmpty {
            loadDefaultPresetServers()
        }
    }
    
    public func updateSubscriptionUrl(_ newUrl: String) {
        subscriptionUrl = newUrl
        userDefaults?.set(newUrl, forKey: SharedConstants.subscriptionUrlKey)
    }
    
    public func fetchSubscription() async {
        guard let url = URL(string: subscriptionUrl) else {
            await MainActor.run { self.errorMessage = "Неверный URL подписки" }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(SharedConstants.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            var rawText = String(data: data, encoding: .utf8) ?? ""
            
            // If Base64 encoded, decode it
            if let decodedData = Data(base64Encoded: rawText.trimmingCharacters(in: .whitespacesAndNewlines), options: .ignoreUnknownCharacters),
               let decodedString = String(data: decodedData, encoding: .utf8) {
                rawText = decodedString
            }
            
            let lines = rawText.components(separatedBy: CharacterSet.newlines)
            var parsedServers: [ServerConfig] = []
            
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
                if let server = ServerConfig.parse(uri: trimmed) {
                    parsedServers.append(server)
                }
            }
            
            if parsedServers.isEmpty {
                // If remote parsing had 0 valid links, keep defaults
                throw NSError(domain: "VPNCLIENT", code: -1, userInfo: [NSLocalizedDescriptionKey: "В подписке не найдено подходящих серверов"])
            }
            
            // Run initial ping check
            let pinged = await PingManager.shared.pingAll(servers: parsedServers)
            
            await MainActor.run {
                self.servers = pinged
                self.lastUpdated = Date()
                self.isLoading = false
                self.saveServers()
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Ошибка обновления: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveServers() {
        if let encoded = try? JSONEncoder().encode(servers) {
            userDefaults?.set(encoded, forKey: SharedConstants.serversListKey)
            userDefaults?.set(Date(), forKey: SharedConstants.lastSyncDateKey)
        }
    }
    
    private func loadCachedServers() {
        if let data = userDefaults?.data(forKey: SharedConstants.serversListKey),
           let cached = try? JSONDecoder().decode([ServerConfig].self, from: data) {
            self.servers = cached
            self.lastUpdated = userDefaults?.object(forKey: SharedConstants.lastSyncDateKey) as? Date
        }
    }
    
    private func loadDefaultPresetServers() {
        self.servers = [
            ServerConfig(
                name: "🇷🇺 LTE 3 (Selectel CDN)",
                host: "78.159.252.30",
                port: 443,
                protocolType: .vless,
                uuid: "33857ba0-be4c-47ea-8d4e-b52ad9b04f38",
                transportType: .splithttp,
                securityType: .tls,
                sni: "ssp.chepushkavpn.fun",
                path: "/selectel-cdn-sp",
                hostHeader: "ssp.chepushkavpn.fun",
                isLTEBypass: true,
                countryCode: "RU",
                pingMs: 24,
                isFavorite: true
            ),
            ServerConfig(
                name: "🇷🇺 LTE 1 (Яндекс CDN)",
                host: "87.250.250.250",
                port: 443,
                protocolType: .vless,
                uuid: "33857ba0-be4c-47ea-8d4e-b52ad9b04f38",
                transportType: .splithttp,
                securityType: .tls,
                sni: "ydx.chepushkavpn.fun",
                path: "/yandex-cdn-sp",
                hostHeader: "ydx.chepushkavpn.fun",
                isLTEBypass: true,
                countryCode: "RU",
                pingMs: 28,
                isFavorite: true
            ),
            ServerConfig(
                name: "🇷🇺 LTE 2 (Cloudflare CDN)",
                host: "104.16.132.229",
                port: 443,
                protocolType: .vless,
                uuid: "33857ba0-be4c-47ea-8d4e-b52ad9b04f38",
                transportType: .splithttp,
                securityType: .tls,
                sni: "cf.chepushkavpn.fun",
                path: "/cf-cdn-sp",
                hostHeader: "cf.chepushkavpn.fun",
                isLTEBypass: true,
                countryCode: "RU",
                pingMs: 32,
                isFavorite: false
            ),
            ServerConfig(
                name: "🇩🇪 Германия Direct (Reality)",
                host: "177.3.214.235",
                port: 443,
                protocolType: .vless,
                uuid: "33857ba0-be4c-47ea-8d4e-b52ad9b04f38",
                flow: "xtls-rprx-vision",
                transportType: .tcp,
                securityType: .reality,
                sni: "gateway.icloud.com",
                fingerprint: "chrome",
                publicKey: "x8r5N1e9L3q2W0zY4vB7mK6pT8uI1oP",
                shortId: "abcd1234",
                isLTEBypass: false,
                countryCode: "DE",
                pingMs: 38,
                isFavorite: true
            ),
            ServerConfig(
                name: "🇳🇱 Нидерланды High-Speed",
                host: "185.220.101.5",
                port: 443,
                protocolType: .vless,
                uuid: "33857ba0-be4c-47ea-8d4e-b52ad9b04f38",
                flow: "xtls-rprx-vision",
                transportType: .tcp,
                securityType: .reality,
                sni: "microsoft.com",
                fingerprint: "chrome",
                publicKey: "k7Q2p9m1N4v8W0zY4vB7mK6pT8uI1oP",
                shortId: "deadbeef",
                isLTEBypass: false,
                countryCode: "NL",
                pingMs: 44,
                isFavorite: false
            ),
            ServerConfig(
                name: "⚡ Hysteria 2 Turbo (DE)",
                host: "177.3.214.235",
                port: 8443,
                protocolType: .hysteria2,
                uuid: "33857ba0-be4c-47ea-8d4e-b52ad9b04f38",
                transportType: .tcp,
                securityType: .tls,
                sni: "de-turbo.chepushkavpn.fun",
                isLTEBypass: false,
                countryCode: "DE",
                pingMs: 41,
                isFavorite: false
            )
        ]
        saveServers()
    }
}
