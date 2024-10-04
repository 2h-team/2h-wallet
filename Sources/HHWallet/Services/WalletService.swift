// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if SKIP
import wallet.core.jni.HDWallet
#else
import WalletCore
#endif


final class WalletService: WalletServiceProtocol {

    static let shared: WalletServiceProtocol = WalletService(storage: SecureWalletStorage())

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
        // SKIP INSERT: System.loadLibrary("TrustWalletCore")
        self.storage = storage
        let wallet = storage.current()

        guard let wallet = wallet else { return }

        self.currentWallet = Wallet(title: wallet.name, mnemonic: wallet.mnemonic)
    }

    var hasWallet: Bool {
        currentWallet != nil
    }

    func createWallet(forceDefault: Bool = false) throws -> Wallet {
        let nameWallet = "Wallet \(storage.load().count + 1)"
#if SKIP
        guard let wallet = HDWallet(128, "") else {
            throw WalletServiceError.errorCreateWallet
        }
        return .init(title: nameWallet, mnemonic: wallet.mnemonic())
#else
        guard let wallet = HDWallet(strength: 128, passphrase: "") else {
            throw WalletServiceError.errorCreateWallet
        }
        return .init(title: nameWallet, mnemonic: wallet.mnemonic)
#endif
    }

    func saveWallet(_ wallet: Wallet, forceDefault: Bool = false) {
        let walletItem = WalletStorageItem(id: wallet.id, name: wallet.title, mnemonic: wallet.mnemonic)

        try? storage.add(walletItem)
        
        if forceDefault || storage.current() == nil {
            try? storage.setCurrent(walletItem)
            currentWallet = .init(title: walletItem.name, mnemonic: walletItem.mnemonic)
        }
    }

    func importWallet(mnemonic: String, forceDefault: Bool = false) throws -> Wallet {
#if SKIP
        guard HDWallet(mnemonic, "") != nil else {
            throw WalletServiceError.invalidMnemonic
        }
#else
        guard HDWallet(mnemonic: mnemonic, passphrase: "") != nil else {
            throw WalletServiceError.invalidMnemonic
        }
#endif
        let nameWallet = "Wallet \(storage.load().count + 1)"
        let extWallet = Wallet(title: nameWallet, mnemonic: mnemonic)
        let walletItem = WalletStorageItem(id: extWallet.id, name: nameWallet, mnemonic: mnemonic)

        guard !storage.exist(extWallet.id) else { throw Error.alreadyExist }

        try? storage.add(walletItem)

        if forceDefault || storage.current() == nil {
            try? storage.setCurrent(walletItem)
            currentWallet = .init(title: walletItem.name, mnemonic: walletItem.mnemonic)
        }

        return .init(title: nameWallet, mnemonic: mnemonic)
    }

    func setDefault(_ wallet: Wallet?) {
        if let wallet = wallet {
            let walletItem = WalletStorageItem(id: wallet.id, name: wallet.title, mnemonic: wallet.mnemonic)

            try? storage.setCurrent(walletItem)
            currentWallet = .init(title: walletItem.name, mnemonic: walletItem.mnemonic)
        } else {
            try? storage.setCurrent(nil)
            currentWallet = nil
        }
    }

    func isValidMnemonic(mnemonic: String) -> Bool {
#if SKIP
        // TODO: - Need use Mnemonic.isValid
        guard let wallet = HDWallet(mnemonic, "") else { return false }
        return true
#else
        return Mnemonic.isValid(mnemonic: mnemonic)
#endif
    }

    func getWallets() -> [Wallet] {
        storage.load().map { Wallet(id: $0.id, title: $0.name, mnemonic: $0.mnemonic) }
    }
}

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
        self.id = mnemonic.sha256()
    }

    init(id: String, title: String, mnemonic: String) {
        self.title = title
        self.mnemonic = mnemonic
        self.id = id
    }

    func wallet() -> HDWallet? {
#if SKIP
        HDWallet(mnemonic, "")
#else
        HDWallet(mnemonic: mnemonic, passphrase: "")
#endif
    }
}
