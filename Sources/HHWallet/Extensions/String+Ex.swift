// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

extension String {
    func maskMnemonic() -> String {
        let words = self.split(separator: " ")
        return words.map { String(repeating: "*", count: $0.count) }.joined(separator: " ")
    }

    func urlEncoded() -> String? {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?
            .replacingOccurrences(of: "&", with: "%26")
    }

    func mask(visibleCount: Int = 4, maskCount: Int = 3) -> String {
        let string = self
        if visibleCount <= 0 { return self }

        var _visibleCount = visibleCount
        var _maskCount = maskCount
        if string.count <= visibleCount * 2 {
            _visibleCount = string.count / 3
        }
        if _maskCount <= 0 {
            _maskCount = string.count - _visibleCount
        }
        let firstPart = string.prefix(_visibleCount)
        let lastPart = string.suffix(_visibleCount)
        let maskString = String(repeating: "*", count: _maskCount)
        return "\(firstPart)\(maskString)\(lastPart)"
    }

    //    func toHexEncodedString(uppercase: Bool = true, prefix: String = "", separator: String = "") -> String {
    //        return unicodeScalars.map { prefix + .init($0.value, radix: 16, uppercase: uppercase) } .joined(separator: separator)
    //    }
    //
    //    func asHex() -> String {
    //        let value = UInt64(littleEndian: UInt64(self) ?? 0)
    //        return String(format:"%08x", value.littleEndian)
    //
    //    }
}
