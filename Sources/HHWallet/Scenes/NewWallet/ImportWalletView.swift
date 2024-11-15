// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ImportWalletView: View {

    @EnvironmentObject var themeManager: ThemeManager

    #if !SKIP
    @Environment(\.presentationMode) var mode
    #endif
    @ObservedObject var viewModel: NewWalletViewModel
    
    @State private var isAllowContinue: Bool = false
    @State private var showMnemonic: Bool = false
    @State private var mnemonic: String = ""

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Enter seed phrase")
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(themeManager.theme.colors.thirdBackground)
                    #if SKIP
                    TextEditor(text: $mnemonic)
                        .textFieldStyle(.roundedBorder)
                        .font(AppFont.bodyMedium)

                    #else
                    TextEditor(text: $mnemonic)
                        .setTextEditorBackground(color: .clear)
                        .padding(10)
                        .font(AppFont.bodyMedium)
                    #endif

                }
                .frame(height: 124)
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
        .toolbarBackground(themeManager.theme.colors.background, for: .navigationBar)
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
