// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

enum AmountFormatter {
    static func format(double: Double, currencyCode: String? = nil, local: Locale = Locale(identifier: "en")) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 5
        formatter.currencyCode = currencyCode
        formatter.currencySymbol = ""
        formatter.locale = local
        return formatter.string(from: double as NSNumber)
    }

    static func format(amount: String, decimals: Int) -> String {
        if amount.count > decimals {
            let amountSuffix = amount.suffix(decimals)
            let amountPrefix = amount.prefix(amount.count - decimals)
            return "\(amountPrefix).\(amountSuffix)"
        } else if amount.count == decimals {
            return "0.\(amount.prefix(5))"
        } else {
            let count = Int(decimals - amount.count)
            return "0.\("\(String(repeating: "0", count: count))\(amount)".prefix(5))"
        }
    }
}
