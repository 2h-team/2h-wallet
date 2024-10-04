// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
#if SKIP
import wallet.core.jni.HDWallet
import wallet.core.jni.CoinType
#else
import WalletCore
#endif

final class MainViewModel: ObservableObject {

    private var networkService: NetworkService
    private var settingsStorage: SettingsStorage
    private var walletService: WalletServiceProtocol

    @Published private(set) var state: State

    init(
        wallet: Wallet,
        networkService: NetworkService = .shared,
        settingsStorage: SettingsStorage = SettingsStorage.shared,
        walletService: WalletServiceProtocol = WalletService.shared
    ) {
        self.walletService = walletService
        self.networkService = networkService
        self.settingsStorage = settingsStorage
        self.state = .init(currentWallet: wallet, currency: settingsStorage.selectedCurrency)
    }

    func trigger(_ action: Action) {
        switch action {
        case .load:
            guard let wallet = walletService.currentWallet?.wallet() else { return }

            state.status = .loading
            let tokens: [NetworkService.BalanceRequest.Token] = settingsStorage.selectedTokens.compactMap { token in

                if let coinType = CoinTypeHelper.getByUInt(token.coinType ?? 0) {
                    #if SKIP
                    return NetworkService.BalanceRequest.Token(
                        id: token.id,
                        // address: $0.address,
                        account: wallet.getAddressForCoin(coinType),
                        coinType: coinType as UInt
                    )
                    #else
                    return NetworkService.BalanceRequest.Token(
                        id: token.id,
                        // address: $0.address,
                        account: wallet.getAddressForCoin(coin: coinType),
                        coinType: coinType.rawValue
                    )
                    #endif

                } else {
                    return nil
                }
            }

            networkService.getBalance(NetworkService.BalanceRequest(
                tokens: tokens,
                currency: settingsStorage.selectedCurrency.uppercased())
            ) { result in
                switch result {
                case .success(let balance):
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.state.estimateBalance = "\(balance.estimateAmount)"
                        self.state.tokens = balance.tokens.map({ extToken in
                            State.Token(
                                extendedToken: extToken,
                                formattedAmount: AmountFormatter.format(double: extToken.amount, currencyCode: self.state.currency) ?? "",
                                formattedValue: AmountFormatter.format(amount: extToken.value, decimals: extToken.token.decimals))
                        })
                        state.status = .loaded
                    }

                case .failure(let error):
                    Task { @MainActor [weak self] in
                        self?.state.status = .error(error.errorMessage)
                    }
                }
            }
        case .changeCurrency(let selectedCurrency):
            state.currency = selectedCurrency.uppercased()
            settingsStorage.selectedCurrency = state.currency
        }
    }
}


extension MainViewModel {
    struct State {
        enum Status {
            case loading, loaded, error(String)
        }
        struct Token: Hashable {
            let extendedToken: ExtendedToken
            let formattedAmount: String
            let formattedValue: String
        }

        var currentWallet: Wallet
        var status: Status = .loading
        var estimateBalance: String = ""
        var currency: String
        var tokens: [Token] = []
    }

    enum Action {
        case load
        case changeCurrency(String)
    }
}
