// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct SelectCurrencyView: View {

    let selectedCurrency: String?
    private let currencies: [String] =  AppViewModel.shared.state.config?.currencies ?? []

    var action:(String) -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Select currency")
                    .font(.body.weight(.semibold))
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
                                    .font(.largeTitle)
                                    .foregroundColor(AppStyle.accentColor)
                                    .opacity(selectedCurrency?.uppercased() == item.uppercased() ? 1.0 : 0.5)

                            }
                            .padding(4)

                        })

                        Divider()
                            .overlay(AppStyle.thirdColor)
                        #if SKIP
                            .opacity(0.1)
                        #endif
                    }
                    Spacer()
                }
            }
        }

    }
}

#Preview {
    SelectCurrencyView(selectedCurrency: nil) { _ in

    }
}
