// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import android.content.Context
#endif
import SwiftUI

struct CompleteWalletView: View {
    @Environment(\.dismiss) var dismiss

    let mode: SelectWalletView.Mode

    @ObservedObject var viewModel: NewWalletViewModel

    @State private var isAllowContinue: Bool = false
    @State private var showMnemonic: Bool = false
    @State private var copiedNotification: Bool = false

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Secret phrase")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.subheadline)
                        .foregroundColor(AppStyle.accentColor)
                    Spacer()
                }
                VStack {
                    Text(showMnemonic ? viewModel.state.mnemonic : viewModel.state.maskedMnemonic)
                        .multilineTextAlignment(.leading)
                        .padding(8)
                        .frame(height: 62)
                    Spacer()
                    HStack(spacing: 4) {
                        ButtonView(text: (showMnemonic ? "Hide" : "Show"), image: nil, style: .secondary) {
                            showMnemonic = !showMnemonic
                        }

                        ButtonView(text: "Copy", image: nil, style: .secondary) {
                            viewModel.trigger(.copy)
                            notify()
                        }
                    }
                    .padding(4)
                }
                .background(AppStyle.thirdColor)
                .cornerRadius(21)
                .frame(height: 142)
                VStack {
                    if copiedNotification {
                        Text("👌 Copied to clipboard!")
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: copiedNotification)
            }
            if !viewModel.state.errorMessage.isEmpty {
                Text(viewModel.state.errorMessage)
                    .foregroundStyle(.red)
                    .padding()
            }
            Spacer()

            VStack(spacing: 32) {
                Toggle(isOn: $isAllowContinue) {
                    Text("I backup mnemonic phrase")
                }

                ButtonView(text: "Complete", image: nil, style: .primary, state: isAllowContinue ? .active : .disable) {
                    viewModel.trigger(.finish)
                    
                    if mode == .default {
                        dismiss()
                    }

                }
            }
        }
        .padding(16)
        .navigationTitle(Text("New"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .onAppear {
            viewModel.trigger(.create)
        }
    }

    func notify() {
        #if !SKIP
        copiedNotification = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedNotification = false
        }
        #else
        // TODO: - Added for android
        #endif
    }
}
