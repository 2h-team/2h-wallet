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
    private var temporaryStorage: TemporaryStorage
    private var walletService: WalletServiceProtocol

    @Published private(set) var state: State

    init(
        wallet: Wallet,
        dependencies: Dependencies = .current
    ) {
        self.walletService = dependencies.walletService
        self.networkService = dependencies.networkService
        self.settingsStorage = dependencies.settingsStorage
        self.temporaryStorage = dependencies.temporaryStorage

        self.state = .init(currentWallet: wallet, currency: settingsStorage.selectedCurrency)
    }

    func trigger(_ action: Action) {
        switch action {
        case .load:
            load()
        case .changeCurrency(let selectedCurrency):
            state.currency = selectedCurrency.uppercased()
            settingsStorage.selectedCurrency = state.currency
        }
    }

    private func load() {
        guard let wallet = walletService.currentWallet?.wallet() else { return }

        state.status = .loading
        let tokens: [NetworkService.BalanceRequest.Token] = settingsStorage.selectedTokens.compactMap { token in
            if let coinTypeInt = token.coinType,
               let coinType = CoinTypeHelper.getByUInt(coinTypeInt) {
                #if SKIP
                let account = wallet.getAddressForCoin(coinType)
                #else
                let account = wallet.getAddressForCoin(coin: coinType)
                #endif
                return NetworkService.BalanceRequest.Token(
                    id: token.id,
                    address: token.address,
                    account: account,
                    coinType: UInt32(coinTypeInt)
                )

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
                let balanceValue = "\(balance.estimateAmount)"
                let tokens = balance.tokens.map({ extToken in
                    State.Token(
                        extendedToken: extToken,
                        formattedAmount: AmountFormatter.format(double: extToken.amount, currencyCode: balance.currency) ?? "",
                        formattedValue: AmountFormatter.format(amount: extToken.value, decimals: extToken.token.decimals), 
                        formattedPrice: AmountFormatter.format(double: extToken.price, currencyCode: balance.currency) ?? ""
                    )
                })
                let tokensBalance = Dictionary(uniqueKeysWithValues: tokens.map { ($0.extendedToken.token.id, $0) })

                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    
                    self.state.estimateBalance = balanceValue
                    self.state.tokens = tokens
                    self.state.tokensBalance = tokensBalance
                    self.state.status = .loaded

                    self.temporaryStorage.tokensBalance = tokensBalance
                }

            case .failure(let error):
                Task { @MainActor [weak self] in
                    self?.state.status = .error(error.errorMessage)
                }
            }
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
            let formattedPrice: String
        }

        var currentWallet: Wallet
        var status: Status = .loading
        var estimateBalance: String = ""
        var currency: String
        var tokens: [Token] = []
        var tokensBalance: [String: Token] = [:]
    }

    enum Action {
        case load
        case changeCurrency(String)
    }
}
