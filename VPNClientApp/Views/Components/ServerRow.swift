//
//  ServerRow.swift
//  VPNCLIENT
//

import SwiftUI

public struct ServerRow: View {
    let server: ServerConfig
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Flag / Group Icon
                Text(server.countryCode == "RU" ? "🇷🇺" : (server.countryCode == "DE" ? "🇩🇪" : (server.countryCode == "NL" ? "🇳🇱" : "🌐")))
                    .font(.system(size: 26))
                    .frame(width: 38, height: 38)
                    .background(AppColors.cardSurface)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(server.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        
                        if server.isLTEBypass {
                            Text("LTE BYPASS")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(AppColors.purple)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(AppColors.purple.opacity(0.18))
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text(server.protocolType.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.cyan)
                        
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.textMuted)
                        
                        Text(server.transportType.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        
                        if server.securityType == .reality {
                            Text("• Reality")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.green)
                        }
                    }
                }
                
                Spacer()
                
                // Ping & Favorite
                VStack(alignment: .trailing, spacing: 6) {
                    PingIndicator(pingMs: server.pingMs)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.cyan)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppColors.cardSurface : AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? AppColors.cyan.opacity(0.8) : AppColors.cardBorder.opacity(0.5), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
