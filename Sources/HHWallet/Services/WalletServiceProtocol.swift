// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

protocol WalletServiceProtocol {

    var hasWallet: Bool { get }
    var currentWallet: Wallet? { get }

    func createWallet(forceDefault: Bool) throws -> Wallet
    func saveWallet(_ wallet: Wallet, forceDefault: Bool)
    func importWallet(mnemonic: String, forceDefault: Bool) throws -> Wallet
    func isValidMnemonic(mnemonic: String) -> Bool
    func setDefault(_ wallet: Wallet?)
    func getWallets() -> [Wallet]
    
}
