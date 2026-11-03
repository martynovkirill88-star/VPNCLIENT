//
//  GlassCard.swift
//  VPNCLIENT
//

import SwiftUI

public struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var borderColor: Color
    
    public init(
        cornerRadius: CGFloat = 18,
        borderColor: Color = AppColors.cardBorder,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding()
            .glassCard(cornerRadius: cornerRadius, borderColor: borderColor)
    }
}
