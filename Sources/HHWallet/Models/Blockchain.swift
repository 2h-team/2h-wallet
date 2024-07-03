// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

struct Blockchain: Decodable, Encodable {
    let id: String
    let coinType: Int
    let sip44: Int?
    let name: String
    let shortname: String
    let cgNativeCoinId: String?
    let nativeDecimals: Int
    let logoURI: String?
}
