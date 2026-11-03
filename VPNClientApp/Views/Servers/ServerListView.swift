//
//  ServerListView.swift
//  VPNCLIENT
//

import SwiftUI

public struct ServerListView: View {
    @ObservedObject var subManager = SubscriptionManager.shared
    @ObservedObject var vpnManager = VPNManager.shared
    @ObservedObject var pingManager = PingManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var searchText: String = ""
    @State private var showingDetail: ServerConfig?
    
    private var filteredServers: [ServerConfig] {
        var list = subManager.servers
        
        switch selectedTab {
        case 1: // LTE Only
            list = list.filter { $0.isLTEBypass }
        case 2: // Wi-Fi Direct Only
            list = list.filter { !$0.isLTEBypass }
        case 3: // Favorites
            list = list.filter { $0.isFavorite }
        default:
            break
        }
        
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.host.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if subManager.servers.isEmpty {
                    VStack(spacing: 18) {
                        Spacer()
                        Image(systemName: "server.rack")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.textMuted)
                        
                        Text("Серверы не найдены")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("У вас пока нет загруженных серверов. Перейдите во вкладку «Подписка» и вставьте ссылку вашего провайдера.")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    // Category Segmented Picker
                    Picker("Категория", selection: $selectedTab) {
                        Text("Все (\(subManager.servers.count))").tag(0)
                        Text("🇷🇺 LTE CDN").tag(1)
                        Text("⚡ Wi-Fi").tag(2)
                        Text("⭐ Избранные").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Search & Ping All Bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                            TextField("Поиск сервера...", text: $searchText)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(AppColors.cardSurface)
                        .cornerRadius(10)
                        
                        Button(action: {
                            Task {
                                let pinged = await pingManager.pingAll(servers: subManager.servers)
                                await MainActor.run {
                                    subManager.servers = pinged
                                }
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: pingManager.isPinging ? "arrow.triangle.2.circlepath" : "bolt.fill")
                                    .rotationEffect(.degrees(pingManager.isPinging ? 360 : 0))
                                    .animation(
                                        pingManager.isPinging ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                        value: pingManager.isPinging
                                    )
                                Text(pingManager.isPinging ? "Тест..." : "Пинг")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(AppColors.cyan)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppColors.cardSurface)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Server List
                    List {
                        ForEach(filteredServers) { server in
                            ServerRow(
                                server: server,
                                isSelected: vpnManager.activeServer?.id == server.id,
                                onSelect: {
                                    vpnManager.switchServer(to: server)
                                },
                                onToggleFavorite: {
                                    if let idx = subManager.servers.firstIndex(where: { $0.id == server.id }) {
                                        subManager.servers[idx].isFavorite.toggle()
                                    }
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .contextMenu {
                                Button {
                                    showingDetail = server
                                } label: {
                                    Label("Параметры сервера", systemImage: "info.circle")
                                }
                                Button {
                                    UIPasteboard.general.string = "\(server.name) (\(server.host):\(server.port))"
                                } label: {
                                    Label("Скопировать адрес", systemImage: "doc.on.doc")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await subManager.fetchSubscription()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Серверы")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $showingDetail) { srv in
                ServerDetailView(server: srv)
            }
        }
    }
}
