//
//  MainTabView.swift
//  VPNCLIENT
//

import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    
    public init() {
        // Dark tab bar appearance
        UITabBar.appearance().backgroundColor = UIColor(Color(hex: "080B14"))
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color(hex: "64748B"))
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Главная", systemImage: "bolt.shield.fill")
                }
                .tag(0)
            
            ServerListView()
                .tabItem {
                    Label("Серверы", systemImage: "server.rack")
                }
                .tag(1)
            
            SmartRoutingView()
                .tabItem {
                    Label("Умная Сеть", systemImage: "bolt.horizontal.circle.fill")
                }
                .tag(2)
            
            SubscriptionView()
                .tabItem {
                    Label("Подписка", systemImage: "link.badge.plus")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(AppColors.cyan)
    }
}
