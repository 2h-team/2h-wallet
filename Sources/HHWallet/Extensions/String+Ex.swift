// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if !SKIP
import CryptoKit
#endif

extension String {

    func asURL() -> URL? {
        URL(string: self)
    }

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

    func sha256() -> String {
#if SKIP
        // SKIP INSERT:
        // val data = this.toString().toByteArray()
        // val md = MessageDigest.getInstance("SHA-256")
        // val digest = md.digest(data)
        // return digest.fold("", { str, it -> str + "%02x".format(it) })
#else
        let data = Data(self.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
#endif
    }
}
