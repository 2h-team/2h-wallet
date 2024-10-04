// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

extension Token {
    static let mock: Token = .init(
        id: "ethereum",
        symbol: "ETH",
        name: "Ethereum",
        address: nil,
        decimals: 18,
        logoURI: "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
        coinType: 60,
        blockchainId: "ethereum"
    )
}
