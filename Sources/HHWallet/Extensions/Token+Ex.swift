// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if SKIP
import wallet.core.jni.HDWallet
#else
import WalletCore
#endif

extension Token {

    func getAccountAddress(for wallet: Wallet) -> String? {
        return wallet.wallet()?.getAccountAddress(by: self)
    }

    func getAccountAddress(for wallet: HDWallet) -> String? {
        return wallet.getAccountAddress(by: self)
    }

}
