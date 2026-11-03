//
//  Subscription.swift
//  VPNCLIENT
//

import Foundation

public struct Subscription: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var url: String
    public var uploadBytes: UInt64
    public var downloadBytes: UInt64
    public var totalBytes: UInt64
    public var expireDate: Date?
    public var lastUpdated: Date?
    public var serverCount: Int
    
    public init(
        id: UUID = UUID(),
        name: String = "RemnaWave Cloud",
        url: String,
        uploadBytes: UInt64 = 0,
        downloadBytes: UInt64 = 0,
        totalBytes: UInt64 = 0,
        expireDate: Date? = nil,
        lastUpdated: Date? = nil,
        serverCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.uploadBytes = uploadBytes
        self.downloadBytes = downloadBytes
        self.totalBytes = totalBytes
        self.expireDate = expireDate
        self.lastUpdated = lastUpdated
        self.serverCount = serverCount
    }
}
