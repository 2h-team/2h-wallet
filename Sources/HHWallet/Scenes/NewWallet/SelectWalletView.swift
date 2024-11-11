// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct SelectWalletView: View {
    
    enum Screen: Hashable {
        case newWallet, importWallet
    }
    
    enum Mode {
        case onboarding
        case `default`
    }
    
    let mode: Mode
    
    @EnvironmentObject
    var themeManager: ThemeManager
    
    @StateObject
    private var viewModel = NewWalletViewModel(walletService: WalletService.shared)
    
    @State
    private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        VStack(spacing: 4) {
                            VStack(spacing: 12) {
                                
                                switch mode {
                                case .onboarding:
                                    VStack {
                                        Text("2H")
                                            .font(AppFont.custom(.boldItalic, size: 82))
                                            .foregroundColor(themeManager.theme.colors.text)
                                        #if SKIP
                                            .material3Text { options in
                                                return options.copy(letterSpacing: androidx.compose.ui.unit.TextUnit(Float(-9), androidx.compose.ui.unit.TextUnitType.Sp))
                                            }
                                        #else
                                            .tracking(-9)
                                        #endif
                                        Text("Your crypto wallet for web3 world.")
                                            .font(AppFont.caption)
                                            .foregroundColor(themeManager.theme.colors.secondaryText)
                                        Spacer()
                                    }
                                    .padding(.vertical, 62)
                                case .default:
                                    if viewModel.state.wallets.isEmpty {
                                        ForEach(viewModel.state.wallets, id: \.id) { wallet in
                                            walletItem(title: wallet.title, selected: viewModel.state.selectedWalletId == wallet.id) { selected in
                                                if selected {
                                                    viewModel.trigger(.select(wallet))
                                                }
                                            } menuAction: {
                                                // TODO: -
                                            }
                                        }
                                    } else {
                                        Text("No wallets yet.")
                                            .font(AppFont.caption)
                                            .foregroundColor(themeManager.theme.colors.secondaryText)
                                    }
                                }
                            }
                            .padding(12)
                        }
                        Spacer()
                    }
                }
                .frame(
                    minHeight: 0,
                    maxHeight: .infinity
                )
                VStack(spacing: 8) {
                    HHButton(config: HHButton.Config.secondary(text: "Create new")) {
                        path.append(Screen.newWallet)
                    }
                    
                    HHButton(config: HHButton.Config.secondary(text: "Import wallet", theme: themeManager.theme)) {
                        path.append(Screen.importWallet)
                    }
                }
                .padding(12)
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .importWallet:
                    ImportWalletView(viewModel: viewModel)
                case .newWallet:
                    CompleteWalletView(mode: mode, viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(mode == .onboarding ? "" : "Select wallet")
                            .font(AppFont.navTitle)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)

        }
    }
    
    @ViewBuilder
    func walletItem(title: String, selected: Bool, selectAction:  @escaping (Bool) -> Void, menuAction: @escaping () -> Void) -> some View {
        HStack(alignment: .center) {
            HStack {
                Button {
                    selectAction(!selected)
                } label: {
                    HStack(spacing: 12) {
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        } else {
                            RoundedRectangle(cornerSize: CGSize(width: 12, height: 12))
                                .fill(themeManager.theme.colors.accent.opacity(0.2))
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .clipShape(Circle())
                .foregroundColor(themeManager.theme.colors.accent)
                Text(title)
                    .font(AppFont.body)
                    .foregroundColor(themeManager.theme.colors.accent)
                    .onTapGesture {
                        selectAction(!selected)
                    }
            }
            Spacer()
            Button {
                menuAction()
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                
            }
            .foregroundColor(themeManager.theme.colors.accent)
#if SKIP
            .clipShape(Circle())
#endif
        }
        .padding(8)
    }
}

#Preview {
    SelectWalletView(mode: .onboarding)
        .environmentObject(ThemeManager.default)
}
