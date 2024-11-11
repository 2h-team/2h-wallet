// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

struct Balance: Encodable, Decodable {
    let currency: String
    let estimateAmount: Double
    let tokens: [ExtendedToken]
}

struct ExtendedToken: Codable, Hashable, Equatable {
    let price: Double
    let amount: Double
    let value: String
    let uiValue: Double
    let token: Token
    let change24h: Double?
    let volume24h: Double?
}

struct Token: Codable, Hashable, Equatable, Identifiable {
    let id: String
    let symbol: String
    let name: String?
    let address: String?
    let decimals: Int
    let logoURI: String?
    let coinType: Int?
    let blockchainId: String
}
