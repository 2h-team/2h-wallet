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
    var themeManager: ThemeManager

    @EnvironmentObject 
    var appState: AppViewModel

    @State
    private var path = NavigationPath()

    let mode: Mode

    var body: some View {
        switch mode {
        case .default:
            NavigationStack(path: $path) {
                SelectTokensView(mode: SelectTokensView.Mode.single({ token in
                    path.append(token)
                }))
                .navigationDestination(for: Token.self) { token in
                    QRCodeAccountAddressView(
                        token: token,
                        for: appState.state.selectedWallet
                    )
                    .environmentObject(themeManager)
                }
            }

        case .byAccount(let token):
            QRCodeAccountAddressView(
                token: token,
                for: appState.state.selectedWallet
            )
            .environmentObject(themeManager)
        }

    }

}

#Preview {
    ReceiveView(mode: .byAccount(Token.mock))
}
