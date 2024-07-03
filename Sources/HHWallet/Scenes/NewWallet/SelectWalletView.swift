// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct SelectWalletView: View {

    enum Screen {
        case newWallet, importWallet
    }

    enum Mode {
        case onboarding
        case `default`
    }

    let mode: Mode

    @StateObject private var viewModel = NewWalletViewModel(walletService: WalletServiceWrapper.shared.service)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack(spacing: 4) {
                        VStack(spacing: 12) {
                            if viewModel.state.wallets.isEmpty {
                                switch mode {
                                case .onboarding:
                                    VStack {
                                        Text("2HWallet")
                                            .font(.title)
                                        Spacer()
                                    }
                                case .default:
                                    Text("No wallets yet.")
                                }

                            } else {
                                ForEach(viewModel.state.wallets, id: \.id) { wallet in
                                    walletItem(title: wallet.title, selected: viewModel.state.selectedWalletId == wallet.id) { selected in
                                        if selected {
                                            viewModel.trigger(.select(wallet))
                                        }
                                    } menuAction: {

                                    }
                                }

                            }
                        }
                        .padding(12)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppStyle.thirdColor)
                    }
                    HStack(spacing: 4) {
                        NavigationLink {
                            CompleteWalletView(viewModel: viewModel)
                        } label: {
                            ButtonView.ContentView(text: "Create new", image: nil, style: .secondary, state: .active)
                        }

                        NavigationLink {
                            ImportWalletView(viewModel: viewModel)
                        } label: {
                            ButtonView.ContentView(text: "Import wallet", image: nil, style: .secondary, state: .active)
                        }
                    }
                }
            }
            .navigationTitle(Text(mode == .onboarding ? "" : "Select wallet"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.clear, for: .navigationBar)
        }
    }

    @ViewBuilder
    func walletItem(title: String, selected: Bool, selectAction:  @escaping (Bool) -> Void, menuAction: @escaping () -> Void) -> some View {
        HStack(alignment: .center) {
            HStack(spacing: 12) {
                Button {
                    selectAction(!selected)
                } label: {
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
                Text(title)
                    .font(.body)
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
        }
        .padding(8)
    }
}
