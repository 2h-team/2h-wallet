// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.core.content.ContextCompat
#endif
import Foundation
import SwiftUI

final class NewWalletViewModel: ObservableObject {
    @Published private(set) var state: State

    private let walletService: WalletServiceProtocol
    private var createdWallet: Wallet?
    private var importedMnemonic = ""

    init(walletService: WalletServiceProtocol) {
        self.walletService = walletService

        state = .init(
            wallets: walletService.getWallets(),
            selectedWalletId: walletService.currentWallet?.id
        )
    }

    func trigger(_ action: Action) {
        switch action {
        case .create:
            do {
                let wallet = try walletService.createWallet(forceDefault: false)
                createdWallet = wallet
                var state = self.state
                state.mnemonic = wallet.mnemonic
                state.maskedMnemonic = wallet.mnemonic.maskMnemonic()
                self.state = state
            } catch {
                state.errorMessage = error.localizedDescription
            }

        case .finish:
            guard let wallet = createdWallet else { return }
            
            walletService.saveWallet(wallet, forceDefault: true)
            state.wallets = walletService.getWallets()

            AppViewModel.shared.trigger(.selectedWallet(wallet))
            
        case .validateMnemonic(let mnemonic):
            state.isValidMnemonic = walletService.isValidMnemonic(mnemonic: mnemonic)
            guard state.isValidMnemonic else { return }

            importedMnemonic = mnemonic
        case .importWallet:
            do {
                let wallet = try walletService.importWallet(mnemonic: importedMnemonic, forceDefault: true)
                AppViewModel.shared.trigger(.selectedWallet(wallet))
            } catch {
                state.errorMessage = error.localizedDescription
            }
        case .copy:
            copy(state.mnemonic)
        case .select(let wallet):
            walletService.setDefault(wallet)
            state.selectedWalletId = wallet.id

        }
    }

    func copy(_ text: String) {
        #if SKIP
        let applicationContext = ProcessInfo.processInfo.androidContext
        // SKIP INSERT:
        // val clipboard = ContextCompat.getSystemService(applicationContext, ClipboardManager::class.java)
        // clipboard?.setPrimaryClip(ClipData.newPlainText("", text))
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

@available(iOS 15, *)
extension NewWalletViewModel {
    struct State {
        var mnemonic: String = ""
        var maskedMnemonic: String = ""
        var errorMessage: String = ""
        var isValidMnemonic = false
        var wallets: [Wallet] = []
        var selectedWalletId: String? = nil
    }

    enum Action {
        case create
        case validateMnemonic(String)
        case importWallet
        case finish
        case copy
        case select(Wallet)
    }
}
