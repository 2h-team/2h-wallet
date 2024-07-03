// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

extension URL {
    func appendPathString(_ string: String) -> URL {
        if string.hasPrefix("/") {
            return URL(string: "\(self.absoluteString)\(string)") ?? self
        }

        return URL(string: "\(self.absoluteString)/\(string)") ?? self
    }
}
