//
//  SettingsView.swift
//  VPNCLIENT
//

import SwiftUI

public struct SettingsView: View {
    @AppStorage(SharedConstants.bypassRuTrafficKey, store: UserDefaults(suiteName: SharedConstants.appGroupId))
    private var bypassRuTraffic: Bool = true
    
    @AppStorage(SharedConstants.killSwitchKey, store: UserDefaults(suiteName: SharedConstants.appGroupId))
    private var killSwitch: Bool = false
    
    @AppStorage(SharedConstants.dnsProviderKey, store: UserDefaults(suiteName: SharedConstants.appGroupId))
    private var dnsProvider: String = "Cloudflare (1.1.1.1)"
    
    private let dnsOptions = [
        "Cloudflare (1.1.1.1)",
        "Google (8.8.8.8)",
        "AdGuard DoH (Без рекламы)",
        "Quad9 (Безопасный)"
    ]
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Routing & Bypass
                    VStack(alignment: .leading, spacing: 14) {
                        Text("МАРШРУТИЗАЦИЯ И ОБХОД")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Toggle(isOn: $bypassRuTraffic) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Обход российских сайтов (Direct)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Банки, Госуслуги, Яндекс, VK работают напрямую без задержек VPN")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.cyan))
                        
                        Divider().background(AppColors.cardBorder)
                        
                        Toggle(isOn: $killSwitch) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Kill-Switch")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Блокировать интернет-трафик в случае обрыва VPN-туннеля")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textMuted)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.red))
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    
                    // DNS & Network Parameters
                    VStack(alignment: .leading, spacing: 14) {
                        Text("СЕТЬ И DNS")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            Text("DNS-резолвер:")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Picker("", selection: $dnsProvider) {
                                ForEach(dnsOptions, id: \.self) { opt in
                                    Text(opt).tag(opt)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Divider().background(AppColors.cardBorder)
                        
                        HStack {
                            Text("MTU интерфейса")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text("9000 (Jumbo Frames)")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppColors.cyan)
                        }
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    
                    // App & Core Info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("О ПРИЛОЖЕНИИ")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            Text("Версия клиента")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("1.0.0 (Build 1)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        HStack {
                            Text("Ядро маршрутизации")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("Sing-box / Xray Core 1.8.24")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.cyan)
                        }
                        
                        HStack {
                            Text("Поддержка протоколов")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("VLESS, Reality, XHTTP, Hysteria2")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
