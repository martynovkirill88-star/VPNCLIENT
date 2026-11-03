//
//  LiveTrafficChart.swift
//  VPNCLIENT
//
//  Real-time animated traffic chart.
//

import SwiftUI

public struct LiveTrafficChart: View {
    @ObservedObject var trafficStats = TrafficStatsManager.shared
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("ТРАФИК В РЕАЛЬНОМ ВРЕМЕНИ", systemImage: "waveform.path.ecg")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(AppColors.cyan).frame(width: 6, height: 6)
                        Text("Входящий").font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(AppColors.purple).frame(width: 6, height: 6)
                        Text("Исходящий").font(.system(size: 11)).foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            // Simple Waveform Graph
            GeometryReader { geo in
                ZStack {
                    chartPath(points: trafficStats.downloadHistory, width: geo.size.width, height: geo.size.height)
                        .stroke(AppColors.cyan, lineWidth: 2)
                        .shadow(color: AppColors.cyan.opacity(0.6), radius: 4)
                    
                    chartPath(points: trafficStats.uploadHistory, width: geo.size.width, height: geo.size.height)
                        .stroke(AppColors.purple, lineWidth: 2)
                        .shadow(color: AppColors.purple.opacity(0.6), radius: 4)
                }
            }
            .frame(height: 70)
        }
        .padding()
        .glassCard()
    }
    
    private func chartPath(points: [TrafficPoint], width: CGFloat, height: CGFloat) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        let maxVal = max(100.0, points.map { $0.speedKbps }.max() ?? 100.0)
        let stepX = width / CGFloat(points.count - 1)
        
        for (idx, pt) in points.enumerated() {
            let x = CGFloat(idx) * stepX
            let normalized = CGFloat(pt.speedKbps / maxVal)
            let y = height - (normalized * (height - 10))
            
            if idx == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}
