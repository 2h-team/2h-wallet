// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if SKIP
import wallet.core.jni.HDWallet
#else
import WalletCore
#endif


extension HDWallet {

    func getAccountAddress(by token: Token) -> String? {
        guard
            let coinTypeUInt = token.coinType,
            let coinType = CoinTypeHelper.getByUInt(coinTypeUInt)
        else { return nil }
#if SKIP
        return self.getAddressForCoin(coinType)
#else
        return self.getAddressForCoin(coin: coinType)
#endif
    }
    
}
