//
//  NetworkType.swift
//  VPNCLIENT
//

import SwiftUI

public enum NetworkType: String, Codable, CaseIterable {
    case wifi = "Wi-Fi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case disconnected = "Offline"
    case unknown = "Unknown"
    
    public var displayName: String {
        switch self {
        case .wifi: return "Wi-Fi Сеть"
        case .cellular: return "Мобильная сеть (LTE/5G)"
        case .ethernet: return "Проводная сеть"
        case .disconnected: return "Нет подключения"
        case .unknown: return "Определение..."
        }
    }
    
    public var iconName: String {
        switch self {
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .ethernet: return "cable.connector"
        case .disconnected: return "wifi.slash"
        case .unknown: return "network"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .wifi: return AppColors.cyan
        case .cellular: return AppColors.purple
        case .ethernet: return AppColors.green
        case .disconnected: return AppColors.textMuted
        case .unknown: return AppColors.orange
        }
    }
}
