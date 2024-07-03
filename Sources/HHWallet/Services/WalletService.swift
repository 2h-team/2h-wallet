// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if SKIP
import wallet.core.jni.HDWallet
#else
import WalletCore
#endif

#if !SKIP

import CryptoKit

final class WalletService: WalletServiceProtocol {
    enum Error: Swift.Error, LocalizedError {
        case alreadyExist

        var errorDescription: String? {
            switch self {
            case .alreadyExist:
                "Wallet already added."
            }
        }
    }

    private let storage: WalletStorageProtocol
    private(set) var currentWallet: Wallet?

    init(storage: WalletStorageProtocol) {
        self.storage = storage
        self.currentWallet = .init(storage.current())
    }

    var hasWallet: Bool {
        currentWallet != nil
    }

    func createWallet(forceDefault: Bool = false) throws -> Wallet {
        guard let wallet = HDWallet(strength: 128, passphrase: "") else {
            throw WalletServiceError.errorCreateWallet
        }

        let nameWallet = "Wallet \(storage.load().count + 1)"
        return .init(title: nameWallet, mnemonic: wallet.mnemonic)
    }

    func saveWallet(_ wallet: Wallet, forceDefault: Bool = false) {
        let walletItem = WalletStorageItem(id: wallet.id, name: wallet.title, mnemonic: wallet.mnemonic)

        try? storage.add(walletItem)
        if forceDefault || storage.current() == nil {
            try? storage.setCurrent(walletItem)
            currentWallet = .init(walletItem)
        }
    }

    func importWallet(mnemonic: String, forceDefault: Bool = false) throws -> Wallet {
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            throw WalletServiceError.invalidMnemonic
        }

        let nameWallet = "Wallet \(storage.load().count + 1)"
        let extWallet = Wallet(title: nameWallet, mnemonic: mnemonic)
        let walletItem = WalletStorageItem(id: extWallet.id, name: nameWallet, mnemonic: wallet.mnemonic)

        guard !storage.alreadyExist(extWallet.id) else {
            throw Error.alreadyExist
        }
        try? storage.add(walletItem)
        if forceDefault || storage.current() == nil {
            try? storage.setCurrent(walletItem)
            currentWallet = .init(walletItem)
        }

        return .init(title: nameWallet, mnemonic: wallet.mnemonic)
    }

    func setDefault(_ wallet: Wallet?) {
        if let wallet = wallet {
            let walletItem = WalletStorageItem(id: wallet.id, name: wallet.title, mnemonic: wallet.mnemonic)

            try? storage.setCurrent(walletItem)
            currentWallet = .init(walletItem)
        } else {
            try? storage.setCurrent(nil)
            currentWallet = nil
        }
    }

    func isValidMnemonic(mnemonic: String) -> Bool {
        Mnemonic.isValid(mnemonic: mnemonic)
    }

    func getWallets() -> [Wallet] {
        storage.load().map { Wallet(id: $0.id, title: $0.name, mnemonic: $0.mnemonic) }
    }
}
#endif

enum WalletServiceError: Error {
    case invalidMnemonic, errorCreateWallet
}

struct Wallet: Identifiable {
    let id: String
    let title: String
    let mnemonic: String

    init(title: String, mnemonic: String) {
        self.title = title
        self.mnemonic = mnemonic

        let data = Data(mnemonic.utf8)
        let hashed = SHA256.hash(data: data)
        self.id = hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    init(id: String, title: String, mnemonic: String) {
        self.title = title
        self.mnemonic = mnemonic
        self.id = id
    }

#if SKIP
    func wallet() -> HDWallet? {
        HDWallet(mnemonic, "")
    }

#else
    func wallet() -> HDWallet? {
        HDWallet(mnemonic: mnemonic, passphrase: "")
    }

    init?(_ wallet: WalletStorageItem?) {
        guard let wallet = wallet, let hdWallet = HDWallet(mnemonic: wallet.mnemonic, passphrase: "") else { return nil }
        self.init(title: wallet.name, mnemonic: hdWallet.mnemonic)
    }
    #endif

}

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

#if SKIP
final class KotlinWalletService: WalletServiceProtocol {

    init() { 
        // SKIP INSERT: System.loadLibrary("TrustWalletCore")
    }

    var hasWallet: Bool {
        return false
    }

    var currentWallet: Wallet? {
        nil
    }

    func createWallet(forceDefault: Bool) throws -> Wallet {
        guard let wallet = HDWallet(128, "") else {
            throw WalletServiceError.errorCreateWallet
        }
        return .init(title: "Wallet", mnemonic: wallet.mnemonic())
    }
    
    func saveWallet(_ wallet: Wallet, forceDefault: Bool) {

    }
    
    func importWallet(mnemonic: String, forceDefault: Bool) throws -> Wallet {
        throw WalletServiceError.invalidMnemonic
    }
    
    func isValidMnemonic(mnemonic: String) -> Bool {
        false
    }
    func setDefault(_ wallet: Wallet?) {

    }
    func getWallets() -> [Wallet] {
        []
    }
}
#endif

final class WalletServiceWrapper {
    static let shared = WalletServiceWrapper()

    #if SKIP
    let service: WalletServiceProtocol = KotlinWalletService()
    #else
    let service: WalletServiceProtocol = WalletService(storage: KeychainWalletStorage.shared)
    #endif
}
