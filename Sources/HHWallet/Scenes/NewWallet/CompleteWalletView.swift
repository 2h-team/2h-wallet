// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import android.content.Context
#endif
import SwiftUI

struct CompleteWalletView: View {

    @EnvironmentObject var themeManager: ThemeManager

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
                    Text("Seed phrase (secret):")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(AppFont.subheadline)
                        .foregroundColor(themeManager.theme.colors.accent)
                    Spacer()
                }
                VStack {
                    Text(showMnemonic ? viewModel.state.mnemonic : viewModel.state.maskedMnemonic)
                        .multilineTextAlignment(.leading)
                        .padding(8)
                        .frame(height: 62)
                    Spacer()
                    HStack(spacing: 4) {
                        HHButton(config: .secondary(text: (showMnemonic ? "Hide" : "Show"))) {
                            showMnemonic = !showMnemonic
                        }

                        HHButton(config: .secondary(text: "Copy")) {
                            viewModel.trigger(.copy)
                            notify()
                        }
                    }
                    .padding(4)
                }
                .background(themeManager.theme.colors.thirdBackground)
                .cornerRadius(21)
                .frame(height: 142)

                Text("Please copy the secret to a safe vault or any password manager. If you lose it, you will not be able to recover your wallet.")
                    .multilineTextAlignment(.leading)
                    .font(AppFont.caption)
                    .foregroundColor(themeManager.theme.colors.secondaryText)

                VStack {
                    if copiedNotification {
                        Text("👌 Copied to clipboard!")
                            .font(AppFont.bodyMedium)
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
                    Text("I've saved the seed phrase in a secure vault.")
                        .font(AppFont.caption)
                }

                HHButton(config: .primary(text: "Complete"), state: isAllowContinue ? .active : .disable) {
                    viewModel.trigger(.finish)

                    if mode == .default {
                        dismiss()
                    }
                }
            }
        }
        .padding(16)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("New")
                        .font(AppFont.navTitle)
                }
            }
        }
        .onAppear {
            viewModel.trigger(.create)
        }
        .toolbarBackground(themeManager.theme.colors.background, for: .navigationBar)
    }

    func notify() {
        copiedNotification = true
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 2.0, execute: {
            copiedNotification = false
        })
    }
}
