// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct QRCodeAccountAddressView: View {

    @EnvironmentObject
    var themeManager: ThemeManager

    @State
    private var copiedNotification: Bool = false

    private let url: URL?
    private let token: Token
    private let address: String

    init(token: Token, for wallet: Wallet?) {
        self.token = token
        if let wallet = wallet, let address = token.getAccountAddress(for: wallet) {
            self.address = address
            self.url = QRCodeUtils.generate(for: address)
        } else {
            self.url = nil
            self.address = ""
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {

            HStack {
                Spacer()
                tokenInfoView()
                Spacer()
            }

            VStack(spacing: 12) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 240, height: 240)
                        .cornerRadius(10)
                } placeholder: { }

                Text(address)
                    .font(.caption)
                    .foregroundColor(.black)
            }
            HStack(spacing: 12) {
                HHButton(config: .secondary(text: "Copy")) {
                    UIPasteboard.general.string = address
                    notify()
                }
                ShareLink(item: address) {
                    HHButton.ContentView(config: HHButton.Config.secondary(text: "Share"))
                }
            }
            .padding(20)

            VStack {
                if copiedNotification {
                    Text("👌 Copied to clipboard!")
                        .font(AppFont.bodyMedium)
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .animation(.easeInOut(duration: 0.5), value: copiedNotification)

            Spacer()

            HStack(spacing: 12) {
                HStack(alignment:.top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(themeManager.theme.colors.warningText)

                    Text("warning receive \(token.blockchainId.capitalized)")
                        .font(.caption)
                        .foregroundColor(themeManager.theme.colors.warningText)

                }
                .padding(12)
                .background(themeManager.theme.colors.warningBackground)
                .cornerRadius(20)
            }
            .padding(20)

        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Receive")
                        .font(AppFont.navTitle)
                }
            }
        }
        .toolbarBackground(themeManager.theme.colors.background, for: .navigationBar)
        // .background(themeManager.theme.colors.background)
    }

    @ViewBuilder
    private func tokenInfoView() -> some View {
        HStack(alignment: .center) {
            AsyncImage(url: URL(string: token.logoURI ?? "")) { image in
                image.resizable()
                    .frame(width: 24, height: 24)
                    .cornerRadius(12)
            } placeholder: {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(token.symbol.uppercased())
                        .font(AppFont.bodySemibold)
                    VStack {
                        Text(token.blockchainId.capitalized)
                            .font(AppFont.captionMedium)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(8)
        .cornerRadius(8)
    }

    func notify() {
        copiedNotification = true
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 2.0, execute: {
            copiedNotification = false
        })
    }
}
