// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct ReceiveView: View {

    enum Screen: Hashable {
        case none
        case qr
    }

    enum Mode {
        case `default`
        case byAccount(Token)
    }

    @EnvironmentObject 
    var appState: AppViewModel

    @State
    private var path = NavigationPath()

    let mode: Mode

    var body: some View {
        switch mode {
        case .default:
            NavigationStack(path: $path) {
                SelectTokensView(mode: .single({ token in
                    path.append(token)
                }))
                .navigationDestination(for: Token.self) { token in
                    QRCodeAccountAddressView(token: token, for: appState.state.selectedWallet)
                }
            }
        case .byAccount(let token):
            QRCodeAccountAddressView(token: token, for: appState.state.selectedWallet)
        }

    }

}

struct QRCodeAccountAddressView: View {

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
        VStack {
            Text(address)
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(width: 350, height: 350)
                    .cornerRadius(8)
            } placeholder: { }
            Spacer()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var title: String {
        if let name = token.name {
            return "\(name) (\(token.symbol.uppercased()))"
        }
        return token.symbol
    }
}

#Preview {
    ReceiveView(mode: .byAccount(Token.mock))
}
