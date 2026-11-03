//
//  TrafficStatsManager.swift
//  VPNCLIENT
//
//  Formats speeds and maintains rolling historical datapoints for live charts.
//

import Foundation
import SwiftUI

public struct TrafficPoint: Identifiable {
    public let id = UUID()
    public let date: Date
    public let speedKbps: Double
}

public final class TrafficStatsManager: ObservableObject {
    public static let shared = TrafficStatsManager()
    
    @Published public var downloadHistory: [TrafficPoint] = []
    @Published public var uploadHistory: [TrafficPoint] = []
    
    private let maxPoints = 25
    
    private init() {
        // Initialize with zeros
        let now = Date()
        for i in 0..<maxPoints {
            let d = now.addingTimeInterval(Double(-maxPoints + i))
            downloadHistory.append(TrafficPoint(date: d, speedKbps: 0))
            uploadHistory.append(TrafficPoint(date: d, speedKbps: 0))
        }
    }
    
    public func record(downBytesPerSec: Double, upBytesPerSec: Double) {
        let now = Date()
        let downKb = downBytesPerSec / 1024.0
        let upKb = upBytesPerSec / 1024.0
        
        DispatchQueue.main.async {
            self.downloadHistory.append(TrafficPoint(date: now, speedKbps: downKb))
            if self.downloadHistory.count > self.maxPoints {
                self.downloadHistory.removeFirst()
            }
            
            self.uploadHistory.append(TrafficPoint(date: now, speedKbps: upKb))
            if self.uploadHistory.count > self.maxPoints {
                self.uploadHistory.removeFirst()
            }
        }
    }
    
    public static func formatSpeed(_ bytesPerSec: Double) -> String {
        if bytesPerSec >= 1_048_576 {
            return String(format: "%.1f MB/s", bytesPerSec / 1_048_576.0)
        } else if bytesPerSec >= 1024 {
            return String(format: "%.0f KB/s", bytesPerSec / 1024.0)
        } else {
            return String(format: "%.0f B/s", bytesPerSec)
        }
    }
    
    public static func formatBytes(_ bytes: UInt64) -> String {
        let d = Double(bytes)
        if d >= 1_073_741_824 {
            return String(format: "%.2f GB", d / 1_073_741_824.0)
        } else if d >= 1_048_576 {
            return String(format: "%.1f MB", d / 1_048_576.0)
        } else if d >= 1024 {
            return String(format: "%.0f KB", d / 1024.0)
        } else {
            return "\(bytes) B"
        }
    }
    
    public static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
