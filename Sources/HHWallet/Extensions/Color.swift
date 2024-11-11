// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

extension Color {

    public static func fromHex(_ hex: Int, opacity: Double = 1.0) -> Color {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
