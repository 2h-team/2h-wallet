// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
#if !SKIP
import KeychainAccess
#endif
struct WalletStorageItem: Codable {
    let id: String
    let name: String
    let mnemonic: String
}

protocol WalletStorageProtocol {
    func current() -> WalletStorageItem?
    func load() -> [WalletStorageItem]
    func add(_ wallet: WalletStorageItem) throws
    func alreadyExist(_ id: String) -> Bool
    func setCurrent(_ wallet: WalletStorageItem?) throws
    func deleteAll() throws
}
#if !SKIP
final class KeychainWalletStorage: WalletStorageProtocol {
    static let shared = KeychainWalletStorage()

    private enum Keys: String {
        case service = "hh-wallet", items, current
    }

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let keychain = Keychain(service: Keys.service.rawValue)
        .accessibility(.whenUnlocked)
        .synchronizable(true)

    func current() -> WalletStorageItem? {
        guard let data = try? keychain.getData(Keys.current.rawValue) else { return nil }
        return try? decoder.decode(WalletStorageItem.self, from: data)
    }

    func load() -> [WalletStorageItem] {
        do {
            guard let data = try keychain.getData(Keys.items.rawValue) else { return [] }
            return try decoder.decode([WalletStorageItem].self, from: data)
        } catch {
            return []
        }
    }

    func add(_ wallet: WalletStorageItem) throws {
        var items = load()
        items.append(wallet)
        items = items.filter { $0.id == wallet.id }
        try save(items)
    }

    func alreadyExist(_ id: String) -> Bool {
        var items = load()
        return items.contains { $0.id == id }
    }

    func setCurrent(_ wallet: WalletStorageItem?) throws {
        guard let wallet = wallet else {
            try keychain.remove(Keys.current.rawValue)
            return
        }
        let data = try encoder.encode(wallet)
        guard let json = String(data: data, encoding: .utf8) else { return }
        try keychain.set(json, key: Keys.current.rawValue)
    }

    func deleteAll() throws {
        try keychain.set("[]", key: Keys.items.rawValue)
    }

    private func save(_ items: [WalletStorageItem]) throws {
        let data = try encoder.encode(items)
        try keychain.set(String(data: data, encoding: .utf8) ?? "[]", key: Keys.items.rawValue)
    }
}
#endif
