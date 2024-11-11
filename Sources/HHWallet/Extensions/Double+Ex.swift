// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

extension Double {

    func asChangePercent() -> String {
        return "\(self >= 0 ? "↗" : "↙") \(String(format: "%.2f", self))"
    }

}
