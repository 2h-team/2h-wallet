// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

enum DisplayMode: Int, Codable {

    case system = 0, dark, light

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return ColorScheme.dark
        case .light: return ColorScheme.light
        }
    }

}
