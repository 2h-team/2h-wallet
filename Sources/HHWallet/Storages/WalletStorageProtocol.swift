// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

struct WalletStorageItem: Codable {
    let id: String
    let name: String
    let mnemonic: String
}

protocol WalletStorageProtocol {
    func current() -> WalletStorageItem?
    func load() -> [WalletStorageItem]
    func add(_ wallet: WalletStorageItem) throws
    func exist(_ id: String) -> Bool
    func setCurrent(_ wallet: WalletStorageItem?) throws
    func deleteAll() throws
}
