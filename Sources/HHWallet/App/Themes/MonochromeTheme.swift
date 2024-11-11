// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

final class MonochromeColors: ColorsConfig {

    var colorScheme: ColorScheme?

    var accent: Color { primary(isDark: colorScheme == .dark) }

    var text: Color { color(0x101010, 0xF1F1F1) }

    var secondaryText: Color { outline(isDark: colorScheme == .dark) }

    var background: Color { background(isDark: colorScheme == .dark) }

    var secondaryBackground: Color { color(0xF6F6F6, 0x151515) }

    var thirdBackground: Color { outlineVariant(isDark: colorScheme == .dark) }

    var buttonBackground: Color { color(0x101010, 0x1E1E1E) }

    var buttonText: Color { color(0xFCFCFC, 0x020202) }

    var secondaryButtonBackground: Color { color(0xE3E3E3, 0x242424) }

    var secondaryButtonText: Color { color(0x101010, 0xF1F1F1) }

    var successText: Color { color(0x57C364, 0x358F40) }

    var failText: Color { color(0xE05A4B, 0xAF3B2E) }

    var warningBackground: Color { color(0xFFEEBE, 0x2B2617) }

    var warningText: Color { color(0x947C39, 0x947A35) }

    init(colorScheme: ColorScheme? = nil) {
        self.colorScheme = colorScheme
    }

    // MARK: - For Android Only

    func primary(isDark: Bool) -> Color {
        color(0x101010, 0xF0F0F0, isDark: isDark)
    }

    func background(isDark: Bool) -> Color {
        color(0xFCFCFC, 0x151515, isDark: isDark)
    }

    func surface(isDark: Bool) -> Color {
        background(isDark: isDark)
    }

    func outline(isDark: Bool) -> Color {
        color(0x5B5B5B, 0x2F2F2F, isDark: isDark)
    }

    func outlineVariant(isDark: Bool) -> Color {
        color(0xF6F6F6, 0x191919, isDark: isDark)
    }


    // MARK: - Private

    private func color(_ anyColorHex: Int, _ forDarkHex: Int) -> Color {
        return color(anyColorHex, forDarkHex, isDark: colorScheme == .dark)
    }

    private func color(_ anyColorHex: Int, _ forDarkHex: Int, isDark: Bool) -> Color {
        if isDark {
            return Color.fromHex(forDarkHex)
        }
        return Color.fromHex(anyColorHex)
    }
}

final class MonochromeAssets: AssetsConfig {

    var colorScheme: ColorScheme?

    init(colorScheme: ColorScheme? = nil) {
        self.colorScheme = colorScheme
    }

}
