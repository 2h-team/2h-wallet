// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

final class SettingsStorage {
    
    private enum Keys: String {
        case selectedCurrency, selectedBlockchain, selectedTokens, colorTheme
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let settings = UserDefaults.standard

    init () {}

    var selectedCurrency: String {
        get {
            settings.string(forKey: Keys.selectedCurrency.rawValue) ?? AppConfig.defaultCurrency
        }

        set {
            settings.set(newValue, forKey: Keys.selectedCurrency.rawValue)
        }
    }

    var selectedBlockchain: Blockchain? {
        get {
            try? decoder.decode(Blockchain.self, from: settings.data(forKey: Keys.selectedBlockchain.rawValue) ?? Data())
        }

        set {
            if let newValue = newValue, let data = try? encoder.encode(newValue) {
                settings.set(data, forKey: Keys.selectedBlockchain.rawValue)
            } else {
                settings.removeObject(forKey: Keys.selectedBlockchain.rawValue)
            }
        }
    }

    var selectedTokens: [Token] {
        get {
            (try? decoder.decode([Token].self, from: settings.data(forKey: Keys.selectedTokens.rawValue) ?? Data())) ?? []
        }

        set {
            if let data = try? encoder.encode(newValue) {
                settings.set(data, forKey: Keys.selectedTokens.rawValue)
            } else {
                settings.removeObject(forKey: Keys.selectedTokens.rawValue)
            }
        }
    }

    var colorTheme: DisplayMode {
        get {
            return DisplayMode(rawValue: settings.integer(forKey: Keys.colorTheme.rawValue) ?? 0) ?? DisplayMode.system
        }

        set {
            settings.set(newValue.rawValue, forKey: Keys.colorTheme.rawValue)
        }
    }
}
