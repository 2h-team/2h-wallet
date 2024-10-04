// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if SKIP
import wallet.core.jni.HDWallet
import wallet.core.jni.CoinType
#else
import WalletCore
#endif

enum CoinTypeHelper {
    static func getByUInt(_ value: Int) -> CoinType? {
        #if SKIP
        return CoinType.values().firstOrNull { $0.value() == value }
        #else
        return CoinType(rawValue: UInt32(value))
        #endif
    }
}
