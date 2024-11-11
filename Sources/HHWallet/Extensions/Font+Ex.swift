// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

enum FontStyle: String {

    case bold = "Bold"
    case boldItalic = "BoldItalic"
    case extraLight = "ExtraLight"
    case extraLightItalic = "ExtraLightItalic"
    case italic = "Italic"
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case mediumItalic = "MediumItalic"
    case semiBold = "SemiBold"
    case semiBoldItalic = "SemiBoldItalic"
    case thin = "Thin"
    case thinItalic = "ThinItalic"

    var fontName: String {
        "IBMPlexMono-\(self.rawValue)"
    }

}

extension Font {

    static func appFont(_ style: FontStyle, size: CGFloat) -> Font {
        Font.custom(style.fontName, size: size)
    }

}

public enum AppFont {

    static let body: Font = Font.appFont(.regular, size: 14)
    static let bodyMedium: Font = Font.appFont(.semiBold, size: 14)
    static let bodySemibold: Font = Font.appFont(.semiBold, size: 14)
    static let bodyBold: Font = Font.appFont(.bold, size: 14)
    static let bodyItalic: Font = Font.appFont(.italic, size: 14)
    static let bodyBoldItalic: Font = Font.appFont(.boldItalic, size: 14)

    static let caption: Font = Font.appFont(.regular, size: 11)
    static let captionMedium: Font = Font.appFont(.medium, size: 11)
    static let caption2: Font = Font.appFont(.medium, size: 10)

    static let subheadline: Font = Font.appFont(.medium, size: 12)

    static let largeTitle: Font = Font.appFont(.regular, size: 42)
    static let largeTitleBold: Font = Font.appFont(.bold, size: 42)

    static let navTitle: Font = Font.appFont(.semiBold, size: 16)

    static func custom(_ style: FontStyle, size: CGFloat) -> Font {
        Font.appFont(style, size: size)
    }

}

