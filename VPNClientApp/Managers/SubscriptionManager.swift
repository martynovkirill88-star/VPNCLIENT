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
    }
    
    public func updateSubscriptionUrl(_ newUrl: String) {
        let trimmed = newUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        subscriptionUrl = trimmed
        userDefaults?.set(trimmed, forKey: SharedConstants.subscriptionUrlKey)
    }
    
    public func clearSubscription() {
        subscriptionUrl = ""
        servers = []
        lastUpdated = nil
        errorMessage = nil
        userDefaults?.removeObject(forKey: SharedConstants.subscriptionUrlKey)
        userDefaults?.removeObject(forKey: SharedConstants.serversListKey)
        userDefaults?.removeObject(forKey: SharedConstants.lastSyncDateKey)
        userDefaults?.removeObject(forKey: SharedConstants.activeServerKey)
    }
    
    public func fetchSubscription() async {
        let trimmedUrl = subscriptionUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUrl.isEmpty else {
            await MainActor.run { self.errorMessage = "Пожалуйста, вставьте ссылку на вашу подписку" }
            return
        }
        
        guard let url = URL(string: trimmedUrl) else {
            await MainActor.run { self.errorMessage = "Неверный формат URL подписки" }
            return
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(SharedConstants.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 12
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw NSError(domain: "VPNCLIENT", code: code, userInfo: [NSLocalizedDescriptionKey: "Сервер подписки ответил ошибкой (HTTP \(code))"])
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
                throw NSError(domain: "VPNCLIENT", code: -1, userInfo: [NSLocalizedDescriptionKey: "В подписке не найдено подходящих серверов (VLESS/Hysteria/VMess)"])
            }
            
            // Test latency
            let pinged = await PingManager.shared.pingAll(servers: parsedServers)
            
            await MainActor.run {
                self.servers = pinged
                self.lastUpdated = Date()
                self.isLoading = false
                self.saveServers()
                
                // If no active server yet, select first
                if VPNManager.shared.activeServer == nil, let first = pinged.first {
                    VPNManager.shared.setActiveServer(first)
                }
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
}
