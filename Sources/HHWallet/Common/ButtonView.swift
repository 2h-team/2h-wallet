// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ButtonView: View {
    
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
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .disabled(state != .active)
        .cornerRadius(style.cornerRadius)

    }

    struct ContentView: View {

        let text: String?
        let image: Image?
        var imageSize: CGFloat = 24.0
        let style: ButtonView.Style
        var state: ButtonView.Status

        var body: some View {
            ZStack {
                switch style {
                case .primary, .apple, .secondary, .plain:
                    Rectangle()
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
        case primary, secondary, apple, plain

        var cornerRadius: CGFloat {
            return 20.0
        }

        var bgColor: Color {
            switch self {
            case .primary:
                Color.accentColor
            case.secondary:
                Color.blue
            case .apple:
                Color.black
            case .plain:
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
            case .plain:
                Color.accentColor
            }
        }
    }

    enum Status {
        case active, loading, disable
    }
}

#if !SKIP
struct AnimationPressButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(Animation.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#endif
