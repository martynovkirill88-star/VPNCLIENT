//
//  SubscriptionView.swift
//  VPNCLIENT
//

import SwiftUI

public struct SubscriptionView: View {
    @ObservedObject var subManager = SubscriptionManager.shared
    @State private var inputUrl: String = ""
    @State private var showSuccessBanner = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Subscription URL input card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("ВАША ССЫЛКА НА ПОДПИСКУ", systemImage: "link")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(AppColors.cyan)
                            
                            TextField("https://...", text: $inputUrl)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(AppColors.textPrimary)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            if !inputUrl.isEmpty {
                                Button(action: { inputUrl = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.textMuted)
                                }
                            }
                        }
                        .padding(12)
                        .background(AppColors.cardSurface)
                        .cornerRadius(12)
                        
                        // Action buttons: Paste & Clear
                        HStack(spacing: 10) {
                            Button(action: {
                                if let clip = UIPasteboard.general.string {
                                    inputUrl = clip.trimmingCharacters(in: .whitespacesAndNewlines)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Вставить из буфера")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(AppColors.cyan)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppColors.cardSurface)
                                .cornerRadius(10)
                            }
                            
                            Spacer()
                            
                            if !subManager.servers.isEmpty {
                                Button(action: {
                                    subManager.clearSubscription()
                                    inputUrl = ""
                                }) {
                                    Text("Очистить")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.red)
                                }
                            }
                        }
                        
                        if let error = subManager.errorMessage {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColors.red)
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.red)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Load / Sync button
                        Button(action: {
                            subManager.updateSubscriptionUrl(inputUrl)
                            Task {
                                await subManager.fetchSubscription()
                            }
                        }) {
                            HStack(spacing: 8) {
                                if subManager.isLoading {
                                    ProgressView().tint(.black)
                                    Text("Загрузка серверов...")
                                        .font(.system(size: 15, weight: .bold))
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(subManager.servers.isEmpty ? "Загрузить серверы" : "Обновить подписку")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.cyan)
                            .cornerRadius(14)
                            .neonGlow(color: AppColors.cyan, radius: 8)
                        }
                        .disabled(subManager.isLoading || inputUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(inputUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    
                    // State Banner
                    if subManager.servers.isEmpty {
                        // Empty State Info
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 44))
                                .foregroundColor(AppColors.textMuted)
                            
                            Text("Подписка ещё не добавлена")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Скопируйте ссылку на подписку вашего VPN-провайдера (RemnaWave, V2Ray, Marzban, 3X-UI) и вставьте её в поле выше.")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                        .glassCard()
                        .padding(.horizontal)
                    } else {
                        // Active Subscription Info Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Активная подписка")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Серверы загружены и готовы")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.green)
                                }
                                
                                Spacer()
                                
                                Text("\(subManager.servers.count) серверов")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppColors.cyan)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppColors.cyan.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            
                            Divider().background(AppColors.cardBorder)
                            
                            // Categorized Server breakdown
                            let lteCount = subManager.servers.filter { $0.isLTEBypass }.count
                            let directCount = subManager.servers.filter { !$0.isLTEBypass }.count
                            
                            HStack(spacing: 12) {
                                HStack(spacing: 6) {
                                    Circle().fill(AppColors.purple).frame(width: 8, height: 8)
                                    Text("Мобильные LTE CDN: \(lteCount)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Circle().fill(AppColors.cyan).frame(width: 8, height: 8)
                                    Text("Wi-Fi Direct: \(directCount)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            
                            if let updated = subManager.lastUpdated {
                                HStack {
                                    Text("Последнее обновление:")
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColors.textMuted)
                                    Spacer()
                                    Text(updated, style: .time)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(AppColors.textMuted)
                                }
                            }
                        }
                        .padding()
                        .glassCard()
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Подписка")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                inputUrl = subManager.subscriptionUrl
            }
        }
    }
}
