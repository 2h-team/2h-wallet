// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct SelectCurrencyView: View {

    @EnvironmentObject 
    var themeManager: ThemeManager

    let selectedCurrency: String?
    var action:(String) -> Void

    private let currencies: [String] =  AppViewModel.shared.state.config?.currencies ?? []

    var body: some View {
        VStack {
            HStack {
                Text("Select currency")
                    .font(AppFont.bodySemibold)
            }
            .padding(12)
            ScrollView {
                VStack {
                    ForEach(currencies, id: \.self) { item in
                        Button(action: {
                            action(item)
                        }, label: {
                            HStack {
                                Text(item.uppercased())
                                    .font(selectedCurrency?.uppercased() == item.uppercased() ? AppFont.largeTitleBold : AppFont.largeTitle)
                                    .foregroundColor(themeManager.theme.colors.accent)
                                    .opacity(selectedCurrency?.uppercased() == item.uppercased() ? 1.0 : 0.5)
                            }
                            .padding(4)
                        })

                        Divider()
                            .overlay(themeManager.theme.colors.thirdBackground)
                        #if SKIP
                            .opacity(0.1)
                        #endif
                    }
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .background(themeManager.theme.colors.background)
        .ignoresSafeArea()
    }
}

#Preview {
    SelectCurrencyView(selectedCurrency: nil) { _ in

    }
}
