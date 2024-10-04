// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI
import Combine

final class SelectTokensViewModel: ObservableObject {

    private var settingsStorage: SettingsStorage
    private var networkService: NetworkService
    private var searchText: String = ""
    private var blockchain: Blockchain?
    private var selectedTokens: [Token]
    private let limit = 40
    private let searchSubject = PassthroughSubject<String, Never>()
    private var searchCancellable: AnyCancellable?

    @Published private(set) var state: State

    init(networkService: NetworkService = .shared, settingsStorage: SettingsStorage = .shared) {
        self.networkService = networkService
        self.settingsStorage = settingsStorage
        self.selectedTokens = settingsStorage.selectedTokens

        self.state = .init(selectedTokens: Dictionary(uniqueKeysWithValues: self.selectedTokens.map { ($0.id, true) }))
        if let config = AppViewModel.shared.state.config {
            self.state.blockchains = Dictionary(uniqueKeysWithValues: config.blockchains.map { ($0.id, $0) })
        }

    }

    func trigger(_ action: Action) {
        switch action {
        case .load:
            search()
        case .search(let string):
            searchCancellable?.cancel()
            searchCancellable = searchSubject
                .receive(on: RunLoop.main)
                .debounce(for: 0.3, scheduler: RunLoop.main)
                .sink { value in
                    self.searchText = value
                    self.state.tokens = []
                    self.search()
                }

            searchSubject.send(string)

        case .selectBlockchain(let blockchain):
            state.blockchain = blockchain
            self.state.tokens = []
            search()

        case .selectToken(let token, let add):
            if add {
                selectedTokens.append(token)
                state.selectedTokens[token.id] = true
            } else {
                selectedTokens = selectedTokens.filter { $0.id != token.id }
                state.selectedTokens[token.id] = false
            }

            settingsStorage.selectedTokens = Array(Set<Token>(selectedTokens))
            // TODO: - Not work
        }
    }

    private func search() {
        var blockchains: [Blockchain] = []
        if let blockchain = state.blockchain {
            blockchains = [blockchain]
        }
        networkService.getTokens(limit: limit, offset: state.tokens.count, q: searchText, blockchains: blockchains) { result in
            switch result {
            case .success(let tokens):
                let selectItems: [SelectItem] = tokens.map { token in SelectItem(token: token, selected: self.selectedTokens.contains(where: { token2 in
                    token.id == token2.id
                }))}

                Task { @MainActor in
                    self.state.tokens.append(contentsOf: selectItems)
                    self.state.isFinished = selectItems.count < self.limit
                }
            case .failure:
                Task { @MainActor in
                    self.state.isFinished = true
                }

            }
        }
    }
}

extension SelectTokensViewModel {

    struct SelectItem: Hashable {
        let token: Token
        var selected: Bool
    }

    struct State {
        var tokens: [SelectItem] = []
        var blockchain: Blockchain?
        var isFinished: Bool = false
        var blockchains: [String: Blockchain] = [:]
        var selectedTokens: [String: Bool] = [:]
    }

    enum Action {
        case load
        case search(String)
        case selectBlockchain(Blockchain?)
        case selectToken(Token, Bool)
    }
}
