//
//  VPNClientApp.swift
//  VPNCLIENT
//
//  SwiftUI App Entrypoint.
//

import SwiftUI

@main
struct VPNClientApp: App {
    @StateObject private var vpnManager = VPNManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var smartRouting = SmartRoutingManager.shared
    @StateObject private var subManager = SubscriptionManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(vpnManager)
                .environmentObject(networkMonitor)
                .environmentObject(smartRouting)
                .environmentObject(subManager)
                .preferredColorScheme(.dark)
        }
    }
}
