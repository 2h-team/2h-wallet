// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ButtonView: View {
    
//    @Environment(\.colorScheme) var colorScheme

    let text: String?
    let image: Image?
    var imageSize: CGFloat = 24.0
    let style: Style
    var state: Status = .active
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            ContentView(text: text, image: image, imageSize: imageSize, style: style, state: state)
        })
        .disabled(state != .active)
    }

    struct ContentView: View {

//        @Environment(\.colorScheme) var colorScheme

        let text: String?
        let image: Image?
        var imageSize: CGFloat = 24.0
        let style: ButtonView.Style
        var state: ButtonView.Status
        var body: some View {
            ZStack {
                switch style {
                case .primary, .apple, .secondary, .clear:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(style.bgColor)
                }
                HStack(alignment: .center, spacing: 12) {
                    if let text = text {
                        Text(text)
                            .foregroundStyle(style.textColor(true))
                    }
                    if let image = image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageSize, height: imageSize)
                    }
                }
            }
            .frame(width: isSquare ? heightSize : nil, height: heightSize)
            .opacity(state == .active ? 1.0 : 0.4)
        }

        private var isSquare: Bool {
            return text == nil
        }

        private var heightSize: CGFloat {
            return 52.0
        }
    }
}

extension ButtonView {

    enum Style {
        case primary, secondary, apple, clear

        var bgColor: Color {
            switch self {
            case .primary:
                Color.accentColor
            case.secondary:
                AppStyle.secondaryColor
            case .apple:
                Color.black
            case .clear:
                Color.clear
            }
        }

        func textColor(_ dark: Bool) -> Color {
            switch self {
            case .primary:
                dark ? .black : .accentColor
            case.secondary:
                Color.accentColor
            case .apple:
                Color.accentColor
            case .clear:
                Color.accentColor
            }
        }
    }

    enum Status {
        case active, loading, disable
    }
}
