//
//  SmartRoutingView.swift
//  VPNCLIENT
//
//  Intelligent Wi-Fi / LTE Network Auto-Routing control screen.
//

import SwiftUI

public struct SmartRoutingView: View {
    @ObservedObject var smartRouting = SmartRoutingManager.shared
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Master Smart Switch
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Умный Автовыбор Сети")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Автоматически переключает серверы при смене сотовой сети и Wi-Fi")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $smartRouting.smartRoutingEnabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: AppColors.cyan))
                        }
                        
                        Divider().background(AppColors.cardBorder)
                        
                        HStack(spacing: 8) {
                            Image(systemName: networkMonitor.currentType.iconName)
                                .foregroundColor(networkMonitor.currentType.accentColor)
                            Text("Текущая сеть: \(networkMonitor.currentType.displayName)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding()
                    .glassCard(borderColor: smartRouting.smartRoutingEnabled ? AppColors.cyan.opacity(0.4) : AppColors.cardBorder)
                    .padding(.horizontal)
                    
                    // Cellular (LTE / 5G) Rules
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("МОБИЛЬНАЯ СЕТЬ (LTE / 5G)", systemImage: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.purple)
                            Spacer()
                        }
                        
                        Toggle("Автоподключение при переходе на LTE", isOn: $smartRouting.autoConnectOnCellular)
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.purple))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Правило маршрутизации:")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Picker("Правило LTE", selection: $smartRouting.cellularPolicy) {
                                ForEach(CellularRoutingPolicy.allCases, id: \.self) { policy in
                                    Text(policy.title).tag(policy)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.cardSurface)
                            .cornerRadius(10)
                        }
                        
                        Text(smartRouting.cellularPolicy.description)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textMuted)
                            .padding(.top, 2)
                    }
                    .padding()
                    .glassCard(borderColor: AppColors.purple.opacity(0.3))
                    .padding(.horizontal)
                    
                    // Wi-Fi Rules
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("БЕСПРОВОДНАЯ СЕТЬ (WI-FI)", systemImage: "wifi")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.cyan)
                            Spacer()
                        }
                        
                        Toggle("Автоподключение при переходе на Wi-Fi", isOn: $smartRouting.autoConnectOnWiFi)
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.cyan))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Правило маршрутизации:")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Picker("Правило Wi-Fi", selection: $smartRouting.wifiPolicy) {
                                ForEach(WiFiRoutingPolicy.allCases, id: \.self) { policy in
                                    Text(policy.title).tag(policy)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.cardSurface)
                            .cornerRadius(10)
                        }
                        
                        Text(smartRouting.wifiPolicy.description)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textMuted)
                            .padding(.top, 2)
                    }
                    .padding()
                    .glassCard(borderColor: AppColors.cyan.opacity(0.3))
                    .padding(.horizontal)
                    
                    // How it works card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("КАК ЭТО РАБОТАЕТ")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("1. При выходе из дома телефон переключается на LTE. VPN автоматически активирует группу серверов Selectel / Яндекс CDN (SplitHTTP), обходя замедление YouTube и ТСПУ.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("2. При возвращении на Wi-Fi клиент моментально переключается на сервер с наименьшим пингом (Германия Reality) без CDN-оверхеда.")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Умная Сеть")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
