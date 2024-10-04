// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import SwiftUI

final class AppViewModel: ObservableObject {

    public static let shared: AppViewModel = .init()

    @Published private(set) var state: State

    private let walletService: WalletServiceProtocol
    private let networkingService: NetworkService

    private init(walletService: WalletServiceProtocol = WalletService.shared, networkingService: NetworkService = .shared) {
        self.walletService = walletService
        self.networkingService = networkingService

        state = .init(selectedWallet: nil, status: State.Status.loading)
    }

    func trigger(_ action: Action) {
        switch action {
        case .selectedWallet(let wallet):
            state.selectedWallet = wallet
        case .loadConfig:
            state.status = .loading
            networkingService.getConfig { result in
                Task { @MainActor in
                    switch result {
                    case .success(let config):
                        self.state.status = .loaded
                        self.state.config = config
                        self.state.selectedWallet = self.walletService.currentWallet
                    case .failure(let error):
                        // self.state.status = .error(error.errorMessage)
                        
                        // TODO: - Remove. Need for test
                        self.state.status = .loaded
                        self.state.config = .default
                        self.state.selectedWallet = self.walletService.currentWallet
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

        var selectedWallet: Wallet?
        var config: Resources.Config?
        var status: Status
    }

    enum Action {
        case selectedWallet(Wallet)
        case loadConfig
    }
}
