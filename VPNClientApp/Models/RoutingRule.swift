//
//  RoutingRule.swift
//  VPNCLIENT
//

import Foundation

public enum CellularRoutingPolicy: String, Codable, CaseIterable {
    case forceLTE = "force_lte"
    case autoLeastPing = "auto_least_ping"
    case manual = "manual"
    
    public var title: String {
        switch self {
        case .forceLTE: return "🇷🇺 Обход ТСПУ (LTE 1-3 CDN)"
        case .autoLeastPing: return "⚡ Автовыбор (Наименьший пинг)"
        case .manual: return "Ручной выбор сервера"
        }
    }
    
    public var description: String {
        switch self {
        case .forceLTE: return "На мобильной сети автоматически направляет трафик через CDN-серверы для обхода замедлений YouTube и блокировок."
        case .autoLeastPing: return "Автоматически выбирает сервер с минимальной задержкой."
        case .manual: return "Подключается к серверу, выбранному вручную."
        }
    }
}

public enum WiFiRoutingPolicy: String, Codable, CaseIterable {
    case leastPing = "least_ping"
    case directFastest = "direct_fastest"
    case manual = "manual"
    
    public var title: String {
        switch self {
        case .leastPing: return "⚡ Наименьший пинг (Германия / Direct)"
        case .directFastest: return "🚀 Максимальная скорость"
        case .manual: return "Ручной выбор сервера"
        }
    }
    
    public var description: String {
        switch self {
        case .leastPing: return "На домашнем или офисном Wi-Fi подключается напрямую к зарубежным нодам без CDN с минимальным пингом."
        case .directFastest: return "Выбирает сервер с максимальной пропускной способностью."
        case .manual: return "Подключается к серверу, выбранному вручную."
        }
    }
}
