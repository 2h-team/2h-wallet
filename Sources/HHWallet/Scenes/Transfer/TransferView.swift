// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct TransferView: View {

    enum Screen: Hashable {
        case selectToken
        case amount
        case confirm
    }

    enum Mode {
        case `default`
        case byToken(Token)
    }

    @EnvironmentObject
    var themeManager: ThemeManager

    @EnvironmentObject
    var appState: AppViewModel

    @StateObject 
    private var viewModel: TransferViewModel

    @State
    private var path = NavigationPath()

    let mode: Mode

    init(mode: Mode) {

        self.mode = mode

        switch mode {
        case .default:
            self._viewModel = StateObject(wrappedValue: TransferViewModel())
        case .byToken(let token):
            self._viewModel = StateObject(wrappedValue: TransferViewModel(selectedToken: token))
        }

    }

    var body: some View {
        NavigationStack(path: $path) {
            switch mode {
            case .default:
                SelectTokensView(mode: SelectTokensView.Mode.single({ token in
                    viewModel.trigger(.selectToken(token))
                    path.append(token)
                }))
                .navigationDestination(for: Token.self) { _ in
                    TransferDetailView(viewModel: viewModel) { _ in
                        // TODO: -
                    }
                }
            case .byToken(let token):
                TransferDetailView(viewModel: viewModel, action: { _ in
                    // TODO: - 
                })
            }
        }
    }

}
