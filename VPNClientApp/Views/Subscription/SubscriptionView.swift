//
//  SubscriptionView.swift
//  VPNCLIENT
//

import SwiftUI

public struct SubscriptionView: View {
    @ObservedObject var subManager = SubscriptionManager.shared
    @State private var inputUrl: String = ""
    @State private var showCopiedAlert = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Subscription info card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("RemnaWave Cloud")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Text("Активная подписка")
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
                        
                        // Traffic Usage Progress Bar
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Использовано трафика:")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("54.2 GB / 250 GB")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(AppColors.cardSurface)
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [AppColors.cyan, AppColors.purple]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * 0.22, height: 8)
                                }
                            }
                            .frame(height: 8)
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
                    
                    // URL input card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ССЫЛКА НА ПОДПИСКУ")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(AppColors.cyan)
                            
                            TextField("https://sub...", text: $inputUrl)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(AppColors.textPrimary)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding(12)
                        .background(AppColors.cardSurface)
                        .cornerRadius(12)
                        
                        if let error = subManager.errorMessage {
                            Text(error)
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.red)
                        }
                        
                        Button(action: {
                            subManager.updateSubscriptionUrl(inputUrl)
                            Task {
                                await subManager.fetchSubscription()
                            }
                        }) {
                            HStack {
                                if subManager.isLoading {
                                    ProgressView().tint(.black)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Обновить подписку")
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
                        .disabled(subManager.isLoading)
                    }
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    
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
