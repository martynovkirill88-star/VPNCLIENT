//
//  ServerDetailView.swift
//  VPNCLIENT
//

import SwiftUI

public struct ServerDetailView: View {
    let server: ServerConfig
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Text(server.countryCode == "RU" ? "🇷🇺" : "🇩🇪")
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(server.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack {
                                PingIndicator(pingMs: server.pingMs)
                                
                                if server.isLTEBypass {
                                    Text("LTE CDN Bypass")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(AppColors.purple)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(AppColors.purple.opacity(0.2))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding()
                    .glassCard()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ТЕХНИЧЕСКИЕ ДАННЫЕ")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                        
                        DetailRow(label: "Протокол", value: server.protocolType.displayName)
                        DetailRow(label: "Транспорт", value: server.transportType.displayName)
                        DetailRow(label: "Безопасность", value: server.securityType.displayName)
                        DetailRow(label: "Хост / IP", value: server.host)
                        DetailRow(label: "Порт", value: "\(server.port)")
                        
                        if let sni = server.sni {
                            DetailRow(label: "SNI", value: sni)
                        }
                        if let path = server.path {
                            DetailRow(label: "HTTP Path", value: path)
                        }
                        if let pbk = server.publicKey {
                            DetailRow(label: "Reality Public Key", value: pbk)
                        }
                        if let sid = server.shortId {
                            DetailRow(label: "Reality Short ID", value: sid)
                        }
                        if let flow = server.flow {
                            DetailRow(label: "Flow", value: flow)
                        }
                    }
                    .padding()
                    .glassCard()
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Параметры ноды")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.cyan)
                }
            }
        }
    }
}

public struct DetailRow: View {
    let label: String
    let value: String
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}
