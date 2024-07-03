// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ImportWalletView: View {
    #if !SKIP
    @Environment(\.presentationMode) var mode
    #endif
    @StateObject var viewModel: NewWalletViewModel
    @State private var isAllowContinue: Bool = false
    @State private var showMnemonic: Bool = false
    @State private var mnemonic: String = ""

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Enter mnemonic")
                #if SKIP
                TextEditor(text: $mnemonic)
                #else
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(AppStyle.thirdColor)
                    TextEditor(text: $mnemonic)
                        .setTextEditorBackground(color: .clear)
                        .padding(10)
                }
                .frame(height: 124)
                #endif
                if !viewModel.state.errorMessage.isEmpty {
                    Text(viewModel.state.errorMessage)
                        .foregroundColor(.red)
                }
            }
            Spacer()

            ButtonView(text: "Complete", image: nil, style: .primary, state: viewModel.state.isValidMnemonic ? .active : .disable) {
                viewModel.trigger(.importWallet)
            }
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        }
        .onChange(of: mnemonic, perform: { newValue in
            viewModel.trigger(.validateMnemonic(mnemonic))
        })
        .padding(16)
        .navigationTitle(Text("Import wallet"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
    }

    @ViewBuilder
    func buttonView(title: String, subTitle: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                    .strokeBorder(.white,lineWidth: 1)
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                    Text(subTitle)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                }
                .padding(15)
            }

        })
        .frame(maxHeight: 124)
    }
 }
