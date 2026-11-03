//
//  PulseButton.swift
//  VPNCLIENT
//
//  Glowing interactive connection button with animated pulse waves.
//

import SwiftUI

public struct PulseButton: View {
    @ObservedObject var vpnManager: VPNManager
    let action: () -> Void
    
    @State private var isPulsing = false
    
    public init(vpnManager: VPNManager, action: @escaping () -> Void) {
        self.vpnManager = vpnManager
        self.action = action
    }
    
    private var isConnected: Bool {
        vpnManager.state == .connected
    }
    
    private var isConnecting: Bool {
        vpnManager.state == .connecting || vpnManager.state == .reconnecting
    }
    
    private var buttonColor: Color {
        if isConnected {
            return AppColors.cyan
        } else if isConnecting {
            return AppColors.orange
        } else {
            return AppColors.cardBorder.opacity(0.9)
        }
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            action()
        }) {
            ZStack {
                // Pulsing outer ripple when connected or connecting
                if isConnected || isConnecting {
                    Circle()
                        .stroke(buttonColor.opacity(0.25), lineWidth: 4)
                        .frame(width: 170, height: 170)
                        .scaleEffect(isPulsing ? 1.25 : 0.95)
                        .opacity(isPulsing ? 0 : 0.8)
                        .animation(
                            Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                    
                    Circle()
                        .stroke(buttonColor.opacity(0.4), lineWidth: 2)
                        .frame(width: 155, height: 155)
                        .scaleEffect(isPulsing ? 1.15 : 0.98)
                        .opacity(isPulsing ? 0.2 : 0.9)
                        .animation(
                            Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(0.5),
                            value: isPulsing
                        )
                }
                
                // Outer glow disc
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                buttonColor.opacity(isConnected ? 0.35 : 0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 180, height: 180)
                
                // Main Button Body
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isConnected ? AppColors.cyan.opacity(0.25) : AppColors.cardBackground,
                                isConnected ? AppColors.purple.opacity(0.3) : AppColors.cardSurface
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 130)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        buttonColor,
                                        buttonColor.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .neonGlow(color: buttonColor, radius: isConnected ? 20 : 6)
                
                // Center Icon
                VStack(spacing: 6) {
                    Image(systemName: isConnecting ? "arrow.triangle.2.circlepath" : "power")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(isConnected ? AppColors.cyan : (isConnecting ? AppColors.orange : AppColors.textSecondary))
                        .rotationEffect(.degrees(isConnecting ? 360 : 0))
                        .animation(
                            isConnecting ? Animation.linear(duration: 1.5).repeatForever(autoreverses: false) : .default,
                            value: isConnecting
                        )
                    
                    Text(isConnected ? "STOP" : (isConnecting ? "WAIT" : "START"))
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(isConnected ? AppColors.cyan : AppColors.textMuted)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            isPulsing = true
        }
    }
}
