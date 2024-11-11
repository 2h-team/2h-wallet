// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

final class Dependencies {

    let walletService: WalletServiceProtocol
    let networkService: NetworkService
    let settingsStorage: SettingsStorage
    let temporaryStorage: TemporaryStorage

    private let walletStorage: WalletStorageProtocol

    init(walletStorage: WalletStorageProtocol) {

        self.walletStorage = walletStorage
        self.networkService = .init(APIClient.shared)
        self.walletService = WalletService(storage: walletStorage)
        self.settingsStorage = SettingsStorage()
        self.temporaryStorage = TemporaryStorage()
    }
}

extension Dependencies {
    static let current = Dependencies(walletStorage: SecureWalletStorage())
}
