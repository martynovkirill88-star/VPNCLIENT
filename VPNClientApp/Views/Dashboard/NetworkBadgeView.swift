//
//  NetworkBadgeView.swift
//  VPNCLIENT
//

import SwiftUI

public struct NetworkBadgeView: View {
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @ObservedObject var smartRouting = SmartRoutingManager.shared
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: networkMonitor.currentType.iconName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(networkMonitor.currentType.accentColor)
            
            Text(networkMonitor.currentType.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            if smartRouting.smartRoutingEnabled {
                Circle()
                    .fill(AppColors.cyan)
                    .frame(width: 5, height: 5)
                
                Text(networkMonitor.isCellular ? "Обход LTE" : "leastPing")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.cyan)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.cardBackground.opacity(0.9))
        .cornerRadius(20)
        .overlay(
            Capsule()
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}
