// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

enum Resources {}

extension Resources {
    struct Config: Decodable {
        let settingsIsEnabled: Bool
        let buyIsEnabled: Bool
        let blockchains: [Blockchain]
        let serviceTokens: [String: [Token]]
        let currencies: [String]
    }
}

