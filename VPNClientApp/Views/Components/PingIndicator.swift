//
//  PingIndicator.swift
//  VPNCLIENT
//

import SwiftUI

public struct PingIndicator: View {
    let pingMs: Int?
    
    public init(pingMs: Int?) {
        self.pingMs = pingMs
    }
    
    private var pingColor: Color {
        guard let ping = pingMs else { return AppColors.textMuted }
        if ping < 60 { return AppColors.green }
        else if ping < 130 { return AppColors.cyan }
        else if ping < 220 { return AppColors.orange }
        else { return AppColors.red }
    }
    
    private var pingText: String {
        guard let ping = pingMs else { return "---" }
        return "\(ping) ms"
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(pingColor)
                .frame(width: 7, height: 7)
                .shadow(color: pingColor.opacity(0.8), radius: 3)
            
            Text(pingText)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(pingColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppColors.cardSurface.opacity(0.8))
        .cornerRadius(8)
    }
}
