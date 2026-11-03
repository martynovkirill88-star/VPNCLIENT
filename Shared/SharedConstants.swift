//
//  SharedConstants.swift
//  VPNCLIENT
//

import Foundation

public struct SharedConstants {
    public static let appGroupId = "group.com.vpnclient.app"
    public static let tunnelBundleId = "com.vpnclient.app.PacketTunnel"
    public static let appBundleId = "com.vpnclient.app"
    
    // UserDefaults Keys
    public static let activeServerKey = "vpn_active_server_config"
    public static let serversListKey = "vpn_servers_list"
    public static let smartRoutingEnabledKey = "vpn_smart_routing_enabled"
    public static let autoConnectOnCellularKey = "vpn_auto_connect_cellular"
    public static let autoConnectOnWiFiKey = "vpn_auto_connect_wifi"
    public static let cellularPolicyKey = "vpn_cellular_policy"
    public static let wifiPolicyKey = "vpn_wifi_policy"
    public static let bypassRuTrafficKey = "vpn_bypass_ru_traffic"
    public static let killSwitchKey = "vpn_kill_switch"
    public static let subscriptionUrlKey = "vpn_subscription_url"
    public static let lastSyncDateKey = "vpn_last_sync_date"
    public static let activeOutboundTagKey = "vpn_active_outbound_tag"
    public static let dnsProviderKey = "vpn_dns_provider"
    
    // Default values - EMPTY by default, user enters own subscription
    public static let defaultSubscriptionUrl = ""
    public static let defaultUserAgent = "Happ/4.8.0 (iOS; VPNCLIENT)"
    
    // Notification names
    public static let networkChangedNotification = Notification.Name("com.vpnclient.networkChanged")
    public static let tunnelStatusChangedNotification = Notification.Name("com.vpnclient.tunnelStatusChanged")
    public static let statsUpdatedNotification = Notification.Name("com.vpnclient.statsUpdated")
}
