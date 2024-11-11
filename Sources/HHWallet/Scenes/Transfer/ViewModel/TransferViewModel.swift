// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
import Combine

final class TransferViewModel: ObservableObject {

    private var settingsStorage: SettingsStorage
    private var networkService: NetworkService

    @Published private(set) var state: State
    
    init(selectedToken: Token? = nil, dependencies: Dependencies = .current) {

        self.networkService = dependencies.networkService
        self.settingsStorage = dependencies.settingsStorage

        self.state = State(
            selectedToken: selectedToken,
            balances: dependencies.temporaryStorage.tokensBalance ?? [:]
        )

    }

    func trigger(_ action: Action) {
        switch action {
        case .selectToken(let token):
            state.selectedToken = token
        }
    }
}

extension TransferViewModel {

    enum Action {
        case selectToken(Token)
    }

    struct State {

        struct TransferDetails: Hashable {
            var toAddress: String = ""
            var amount: String = ""
        }

        var selectedToken: Token?
        var details: TransferDetails?
        var maxAmount: String = ""
        var balances: [String: TokenBalance] = [:]
    }

}
