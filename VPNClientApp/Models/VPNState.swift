//
//  VPNState.swift
//  VPNCLIENT
//

import SwiftUI

public enum VPNState: String, Codable {
    case disconnected = "disconnected"
    case connecting = "connecting"
    case connected = "connected"
    case disconnecting = "disconnecting"
    case reconnecting = "reconnecting"
    case error = "error"
    
    public var title: String {
        switch self {
        case .disconnected: return "Отключено"
        case .connecting: return "Подключение..."
        case .connected: return "Подключено"
        case .disconnecting: return "Отключение..."
        case .reconnecting: return "Переподключение..."
        case .error: return "Ошибка сети"
        }
    }
    
    public var glowColor: Color {
        switch self {
        case .disconnected: return AppColors.cardBorder
        case .connecting: return AppColors.orange
        case .connected: return AppColors.cyan
        case .disconnecting: return AppColors.purple
        case .reconnecting: return AppColors.orange
        case .error: return AppColors.red
        }
    }
    
    public var isConnected: Bool {
        return self == .connected
    }
}
