// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

public protocol ColorsConfig {
    
    var colorScheme: ColorScheme? { get set }

    var accent: Color { get }

    var text: Color { get }
    var secondaryText: Color { get }

    var background: Color { get }
    var secondaryBackground: Color { get }
    var thirdBackground: Color { get }

    var buttonBackground: Color { get }
    var buttonText: Color { get }
    var secondaryButtonBackground: Color { get }
    var secondaryButtonText: Color { get }

    var warningBackground: Color { get }
    var warningText: Color { get }

    var successText: Color { get }
    var failText: Color { get }

    // MARK: - For Android

    func primary(isDark: Bool) -> Color
    func background(isDark: Bool) -> Color
    func surface(isDark: Bool) -> Color
    func outline(isDark: Bool) -> Color
    func outlineVariant(isDark: Bool) -> Color
}

public protocol AssetsConfig {

    var colorScheme: ColorScheme? { get set }
    
}

public protocol ThemeProtocol: ObservableObject {
    var colors: ColorsConfig { get }
    var assets: AssetsConfig { get }
}
