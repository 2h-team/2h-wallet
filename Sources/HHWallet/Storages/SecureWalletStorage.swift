// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import SkipKeychain

final class SecureWalletStorage: WalletStorageProtocol {

    private enum Keys: String {
        case items, current
    }

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let keychain = Keychain.shared


    func current() -> WalletStorageItem? {
        guard let json = try? keychain.string(forKey: Keys.current.rawValue), let data = json.data(using: .utf8) else { return nil }
        return try? decoder.decode(WalletStorageItem.self, from: data)
    }

    func load() -> [WalletStorageItem] {
        do {
            guard let json = try keychain.string(forKey: Keys.items.rawValue), let data = json.data(using: .utf8) else { return [] }
            return try decoder.decode([WalletStorageItem].self, from: data)
        } catch {
            return []
        }
    }

    func add(_ wallet: WalletStorageItem) throws {
        var items = load().filter { $0.id != wallet.id }
        items.append(wallet)
        try save(items)
    }

    func exist(_ id: String) -> Bool {
        let items = load()
        return items.contains { $0.id == id }
    }

    func setCurrent(_ wallet: WalletStorageItem?) throws {
        guard let wallet = wallet else {
            try keychain.removeValue(forKey: Keys.current.rawValue)
            return
        }
        let data = try encoder.encode(wallet)
        guard let json = String(data: data, encoding: .utf8) else { return }
        try keychain.set(json, forKey: Keys.current.rawValue)
    }

    func deleteAll() throws {
        try keychain.set("[]", forKey: Keys.items.rawValue)
    }

    private func save(_ items: [WalletStorageItem]) throws {
        let data = try encoder.encode(items)
        try keychain.set(String(data: data, encoding: .utf8) ?? "[]", forKey: Keys.items.rawValue)
    }
}
