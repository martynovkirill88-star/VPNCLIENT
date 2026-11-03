//
//  XrayConfigBuilder.swift
//  PacketTunnel
//

import Foundation

public struct XrayConfigBuilder {
    public static func validateConfig(jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }
}
