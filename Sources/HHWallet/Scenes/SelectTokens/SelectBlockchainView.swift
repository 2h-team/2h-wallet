// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct SelectBlockchainsView: View {

    let selectedBlockchain: Blockchain?
    private let blockchains: [Blockchain] =  AppViewModel.shared.state.config?.blockchains ?? []

    var action:(Blockchain?) -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Select blockchain")
                    .font(.body.weight(.semibold))
            }
            .padding(12)
            ScrollView {
                VStack {
                    Button(action: {
                        action(nil)
                    }, label: {
                        HStack {
                            Text("All blockchains")
                                .font(.largeTitle)
                                .foregroundColor(AppStyle.accentColor)
                                .opacity(selectedBlockchain == nil ? 1.0 : 0.5)

                        }
                        .padding(4)

                    })

                    Divider()
                        .overlay(AppStyle.thirdColor)
                    #if SKIP
                        .opacity(0.1)
                    #endif
                    ForEach(blockchains, id: \.id) { item in
                        Button(action: {
                            action(item)
                        }, label: {
                            HStack {
                                Text(item.name)
                                    .font(.largeTitle)
                                    .foregroundColor(AppStyle.accentColor)
                                    .opacity(selectedBlockchain?.id == item.id ? 1.0 : 0.5)

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
    SelectBlockchainsView(selectedBlockchain: nil) { _ in

    }
}
