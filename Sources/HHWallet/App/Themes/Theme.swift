// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

public final class Theme {

    public let name: String
    public private(set) var colors: ColorsConfig
    public private(set) var assets: AssetsConfig

    init(name: String, colors: ColorsConfig, assents: AssetsConfig) {
        self.name = name
        self.colors = colors
        self.assets = assents
    }

    func update(colorScheme: ColorScheme?) {
        colors.colorScheme = colorScheme
        assets.colorScheme = colorScheme
    }
}

public final class ThemeManager: ObservableObject {

    public static let `default`: ThemeManager = .init(settingsStorage: Dependencies.current.settingsStorage)

    @Published 
    public var theme: Theme
    public let themes: [Theme]

    private let settingsStorage: SettingsStorage

    private init(settingsStorage: SettingsStorage) {
        self.settingsStorage = settingsStorage

        self.themes = [
            Theme(
                name: "Monochrome",
                colors: MonochromeColors(colorScheme: settingsStorage.colorTheme.colorScheme),
                assents: MonochromeAssets(colorScheme: settingsStorage.colorTheme.colorScheme)
            )
        ]

        self.theme = themes.first!
    }

    func changeScheme(colorScheme: ColorScheme?) {
        guard theme.colors.colorScheme != colorScheme else { return }
        
        theme.update(colorScheme: colorScheme)

        if let colorScheme = colorScheme {
            settingsStorage.colorTheme = colorScheme == .dark ? .dark : .light
        } else {
            settingsStorage.colorTheme = .system
        }

        self.objectWillChange.send()
    }
}
