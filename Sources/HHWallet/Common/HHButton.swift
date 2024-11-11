// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct HHButton: View {

    enum Status {
        case active, loading, disable
    }

    let config: Config
    var state: Status = .active
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            ContentView(config: config)
        })
        .disabled(state != .active)
        .opacity(state == .active ? 1.0 : 0.5)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }

    struct ContentView: View {

        let config: Config

        var body: some View {
            ZStack {
                if !config.fitByContent {
                    Rectangle()
                        .fill(config.bgColor)
                }
                HStack(alignment: .center, spacing: config.spacing) {
                    if let imageName = config.imageName {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: ContentMode.fit)
                            .frame(width: config.imageSize, height: config.imageSize)
                            .foregroundColor(config.textColor)
                    }
                    if let text = config.text {
                        Text(text)
                            .foregroundColor(config.textColor)
                            .font(config.font)
                    }
                }
            }
            .frame(width: isSquare ? config.height : nil, height: config.height)
            .padding(config.padding)
            .environment(\.layoutDirection, config.isRtl ? LayoutDirection.rightToLeft : LayoutDirection.leftToRight)
            .background(config.fitByContent ? config.bgColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
        }

        private var isSquare: Bool {
            return config.text == nil
        }
    }
}

extension HHButton {

    struct Config {

        enum SizeType {
            case large
            case `default`
            case medium
            case small
        }

        let text: String?
        let imageName: String?
        let size: SizeType
        let textColor: Color
        let bgColor: Color
        let fitByContent: Bool
        let padding: EdgeInsets
        let font: Font
        let isRtl: Bool
        let imageSize: CGFloat

        var cornerRadius: CGFloat {
            switch size {
            case .large:
                return 19.0
            case .default:
                return 19.0
            case .medium:
                return 13.0
            case .small:
                return 10.0
            }
        }

        var spacing: CGFloat {
            switch size {
            case .large:
                return 8.0
            case .default:
                return 8.0
            case .small, .medium:
                return 6.0
            }
        }

        var height: CGFloat {
            switch size {
            case .large:
                return 58.0
            case .default:
                return 48.0
            case .medium:
                return 36.0
            case .small:
                return 24.0
            }

        }
    }
}

extension HHButton.Config {

    static func primary(
        text: String?,
        imageName: String? = nil,
        size: SizeType = .default,
        fitContent: Bool = false,
        isRtl: Bool = false,
        imageSize: CGFloat? = nil,
        theme: Theme = ThemeManager.default.theme
    ) -> HHButton.Config {

        let padding = fitContent ? EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12) : EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return .init(
            text: size == .default ? text : text?.uppercased(),
            imageName: imageName,
            size: size,
            textColor: theme.colors.buttonText,
            bgColor: theme.colors.buttonBackground,
            fitByContent: fitContent,
            padding: padding,
            font: size == .default ? AppFont.bodyMedium : AppFont.captionMedium,
            isRtl: isRtl,
            imageSize: imageSize ?? getImageSize(size: size)
        )
    }

    static func secondary(
        text: String?,
        imageName: String? = nil,
        size: SizeType = .default,
        fitContent: Bool = false,
        isRtl: Bool = false,
        imageSize: CGFloat? = nil,
        theme: Theme = ThemeManager.default.theme
    ) -> HHButton.Config {

        let padding = fitContent ? EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12) : EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return .init(
            text: size == .default ? text : text?.uppercased(),
            imageName: imageName,
            size: size,
            textColor: theme.colors.secondaryButtonText,
            bgColor: theme.colors.secondaryButtonBackground,
            fitByContent: fitContent,
            padding: padding,
            font: size == .default ? AppFont.bodyMedium : AppFont.captionMedium,
            isRtl: isRtl,
            imageSize: imageSize ?? getImageSize(size: size)
        )
    }

    static private func getImageSize(size: SizeType) -> CGFloat {
        switch size {
        case .large:
            return 32.0
        case .default:
            return 24.0
        case .medium:
            return 19.0
        case .small:
            return 12.0
        }
    }

}

#Preview {
    ScrollView {
        VStack {
            HHButton(config: .primary(text: "text", imageName: nil, size: .default)) { }
            HHButton(config: .primary(text: "text", imageName: nil, size: .medium)) { }
            HHButton(config: .primary(text: "text", imageName: "gearshape.fill", size: .small, fitContent: true)) { }
            HHButton(config: .primary(text: "text", imageName: "gearshape.fill", size: .small, fitContent: true, isRtl: true)) { }
            HHButton(config: .primary(text: "text", imageName: nil, size: .small, fitContent: true)) { }
            HHButton(config: .secondary(text: "text", imageName: "gearshape.fill", size: .small, fitContent: true, isRtl: true)) { }
            HHButton(config: .secondary(text: "text", imageName: "gearshape.fill", size: .small, fitContent: true, isRtl: true)) { }

            HHButton(config: .secondary(text: "text", imageName: "gearshape.fill", size: .small, fitContent: true, isRtl: true), state: .disable) { }
            HHButton(config: .secondary(text: "text", imageName: "gearshape.fill", size: .small, fitContent: true, isRtl: true), state: .loading) { }

            HHButton(config: .secondary(text: "text", imageName: "gearshape.fill", size: .default, fitContent: true, isRtl: true), state: .loading) { }

            HHButton(config: .secondary(text: nil, imageName: "gearshape.fill", size: .default, fitContent: false, isRtl: true), state: .loading) { }
        }
    }

}
