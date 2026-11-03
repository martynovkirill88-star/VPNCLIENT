//
//  Styles.swift
//  VPNCLIENT
//

import SwiftUI

public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 18
    var borderColor: Color = AppColors.cardBorder
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.cardBackground.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
    }
}

public struct NeonGlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 15
    
    public func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 1.8, x: 0, y: 0)
    }
}

extension View {
    public func glassCard(cornerRadius: CGFloat = 18, borderColor: Color = AppColors.cardBorder) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
    
    public func neonGlow(color: Color, radius: CGFloat = 15) -> some View {
        self.modifier(NeonGlowModifier(color: color, radius: radius))
    }
}
