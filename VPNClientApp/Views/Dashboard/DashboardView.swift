//
//  DashboardView.swift
//  VPNCLIENT
//
//  Main application screen with glowing connection button, stats and smart router info.
//

import SwiftUI

public struct DashboardView: View {
    @ObservedObject var vpnManager = VPNManager.shared
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @ObservedObject var smartRouting = SmartRoutingManager.shared
    @ObservedObject var subManager = SubscriptionManager.shared
    
    @State private var showAlertNoSubscription = false
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("VPNCLIENT")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Smart Wi-Fi / LTE Routing")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    NetworkBadgeView()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Smart Routing Status Notification Banner
                if smartRouting.smartRoutingEnabled {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundColor(AppColors.cyan)
                        
                        Text(smartRouting.statusMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppColors.cardSurface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.cyan.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 10)
                
                // Central Pulse Connection Button
                PulseButton(vpnManager: vpnManager) {
                    if subManager.servers.isEmpty {
                        showAlertNoSubscription = true
                    } else {
                        vpnManager.toggleConnection()
                    }
                }
                .padding(.vertical, 10)
                
                // Connection State Label
                VStack(spacing: 4) {
                    Text(vpnManager.state.title.uppercased())
                        .font(.system(size: 16, weight: .heavy, design: .monospaced))
                        .foregroundColor(vpnManager.state.glowColor)
                    
                    if vpnManager.state == .connected {
                        Text(TrafficStatsManager.formatDuration(vpnManager.connectionDuration))
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                    } else if subManager.servers.isEmpty {
                        Text("Добавьте подписку во вкладке «Подписка»")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.orange)
                    } else {
                        Text("Нажмите для подключения")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                // Active Server Card / Empty state
                if let server = vpnManager.activeServer {
                    HStack(spacing: 12) {
                        Text(server.countryCode == "RU" ? "🇷🇺" : "🇩🇪")
                            .font(.system(size: 28))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(server.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(server.protocolType.displayName) • \(server.transportType.displayName)")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        PingIndicator(pingMs: server.pingMs)
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                } else {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.cyan)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Сервер не выбран")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Вставьте ссылку во вкладке «Подписка»")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                }
                
                // Speed & Metrics Cards
                HStack(spacing: 12) {
                    SpeedMetricCard(
                        title: "СКАЧИВАНИЕ",
                        speed: TrafficStatsManager.formatSpeed(vpnManager.downloadSpeedBps),
                        total: TrafficStatsManager.formatBytes(vpnManager.totalDownloadedBytes),
                        icon: "arrow.down.circle.fill",
                        color: AppColors.cyan
                    )
                    
                    SpeedMetricCard(
                        title: "ОТПРАВКА",
                        speed: TrafficStatsManager.formatSpeed(vpnManager.uploadSpeedBps),
                        total: TrafficStatsManager.formatBytes(vpnManager.totalUploadedBytes),
                        icon: "arrow.up.circle.fill",
                        color: AppColors.purple
                    )
                }
                .padding(.horizontal)
                
                // Real-time chart
                LiveTrafficChart()
                    .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .alert(isPresented: $showAlertNoSubscription) {
            Alert(
                title: Text("Подписка не добавлена"),
                message: Text("Перейдите во вкладку «Подписка» и вставьте вашу ссылку на серверы, чтобы начать."),
                dismissButton: .default(Text("Понятно"))
            )
        }
    }
}
