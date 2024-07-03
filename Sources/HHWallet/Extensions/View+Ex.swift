// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
import Foundation

extension View {
    #if !SKIP
    @ViewBuilder
    public func setTextEditorBackground(color: Color) -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
                .background(color)
        } else {
            self.textEditorBackground { color }
        }
    }

    private func textEditorBackground<V>(@ViewBuilder _ content: () -> V) -> some View where V : View {
        self.onAppear { UITextView.appearance().backgroundColor = UIColor.clear }
            .background(content())
    }
    #endif
}
