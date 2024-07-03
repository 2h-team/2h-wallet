// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import SwiftUI

final class AppViewModel: ObservableObject {

    @Published private(set) var state: State

    private let walletService: WalletServiceProtocol
    private let networkingService: NetworkService

    init(walletService: WalletServiceProtocol = WalletServiceWrapper.shared.service, networkingService: NetworkService = .shared) {
        self.walletService = walletService
        self.networkingService = networkingService

        state = .init(walletSelected: false, status: State.Status.loading)
    }

    func trigger(_ action: Action) {
        switch action {
        case .selectedWallet:
            state.walletSelected = true
        case .loadConfig:
            state.status = .loading
            networkingService.getConfig { result in
                Task { @MainActor in
                    switch result {
                    case .success(let success):
                        self.state.status = .loaded
                        self.state.config = success
                        self.state.walletSelected = self.walletService.hasWallet
                    case .failure(let error):
                        self.state.status = .error(error.errorMessage)
                    }
                }
            }
        }
    }
}

@available(iOS 15, *)
extension AppViewModel {

    struct State {
        enum Status {
            case loading, loaded, error(String)
        }

        var walletSelected: Bool
        var config: Resources.Config?
        var status: Status
    }

    enum Action {
        case selectedWallet(Wallet)
        case loadConfig
    }
}
