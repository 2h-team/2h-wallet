// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct MainView: View {

    @EnvironmentObject var appState: AppViewModel

    @StateObject var viewModel: MainViewModel

    @State private var showSelectWallet: Bool = false
    @State private var showSelectCurrency: Bool = false
    @State private var showSelectTokens: Bool = false
    @State private var showReceive: Bool = false

    init(wallet: Wallet) {
        self._viewModel = StateObject(wrappedValue: MainViewModel(wallet: wallet))
    }

    var body: some View {
        content()
        #if !SKIP
        .refreshable {
            viewModel.trigger(.load)
        }
        #else
        // TODO: - add for android
        #endif
        .onAppear {
            viewModel.trigger(.load)
        }
        .sheet(isPresented: $showSelectWallet, content: {
            SelectWalletView(mode: .default)
        })
        .sheet(isPresented: $showReceive, content: {
            ReceiveView(mode: ReceiveView.Mode.default)
                .environmentObject(appState)
        })
        .sheet(isPresented: $showSelectTokens, content: {
            SelectTokensView()
        })
        .sheet(isPresented: $showSelectCurrency, content: {
            SelectCurrencyView(selectedCurrency: viewModel.state.currency) { currency in
                viewModel.trigger(.changeCurrency(currency))
                showSelectCurrency = false
            }
        })
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func content() -> some View {
        ScrollView {
            VStack(spacing: 4) {
#if !SKIP
                VStack { }.frame(height: 52)
#else
                VStack { }.frame(height: 16)
#endif
                HStack(spacing: 4) {
                    selectWalletButton()
                    if appState.state.config?.settingsIsEnabled ?? false {
                        settingsButton()
                    }
                }
                balanceView()
                HStack(spacing: 4) {
                    receiveButton()
                    sendButton()
                    if appState.state.config?.buyIsEnabled ?? false {
                        buyButton()
                    }
                }
                tokensView()
            }
            .padding(4)
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func balanceView() -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                HStack {
                    Text("Your balance")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.subheadline)
                        .foregroundColor(AppStyle.accentColor)
                }
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 0, trailing: 14))
                HStack {
                    Spacer()
                    switch viewModel.state.status {
                    case .loading, .error:
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.gray.opacity(0.1))
                            .frame(width: 120, height: 48)
                    case .loaded:
                        Text(viewModel.state.estimateBalance)
                            .font(.system(size: 54, weight: .light))
                    }

                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 28, trailing: 14))
            }

            Button(action: {
                showSelectCurrency = true
            }, label: {
                Text(viewModel.state.currency)
                    .font(.caption)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(AppStyle.secondaryColor)
                    .cornerRadius(18)

            })
            .offset(CGSize(width: -12.0, height: 12.0))

        }

        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppStyle.thirdColor)
        }
    }

    @ViewBuilder
    private func selectWalletButton() -> some View {
        ButtonView(text: appState.state.selectedWallet?.title ?? "No wallet", image: Image(systemName: "chevron.down"), imageSize: 12.0, style: .secondary) {
            showSelectWallet = true
        }
    }

    @ViewBuilder
    private func settingsButton() -> some View {
        ButtonView(text: nil, image: Image(systemName: "gearshape.fill"), style: .secondary) {
            debugPrint("Click")
        }
    }

    @ViewBuilder
    private func receiveButton() -> some View {
        ButtonView(text: "Receive", image: nil, style: .secondary) {
            showReceive = true
        }
    }

    @ViewBuilder
    private func sendButton() -> some View {
        ButtonView(text: "Send", image: nil, style: .secondary) {
            debugPrint("Click")
        }
    }

    @ViewBuilder
    private func buyButton() -> some View {
        ButtonView(text: "Buy", image: nil, style: .secondary) {
            debugPrint("Click")
        }
    }

    @ViewBuilder
    private func tokensView() -> some View {

        ZStack(alignment: .topTrailing) {
            VStack(spacing: 4) {
                HStack {
                    Text("Tokens")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.subheadline)
                        .foregroundColor(AppStyle.accentColor)
                }
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 0, trailing: 14))

                VStack(spacing: 12) {
                    switch viewModel.state.status {
                    case .loading:
                        TokenSkeletonView()
                        TokenSkeletonView()
                        TokenSkeletonView()
                        TokenSkeletonView()
                    case .loaded:
                        if viewModel.state.tokens.isEmpty {
                            HStack {
                                Spacer()
                                Text("No selected tokens")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .font(.subheadline)
                                    .foregroundColor(AppStyle.accentColor)
                                Spacer()
                            }
                            .padding()

                        } else {
                            ForEach(viewModel.state.tokens, id: \.self) { token in
                                Button(action: {
                                    debugPrint("Click")
                                }, label: {
                                    TokenItemView(
                                        logoURL: token.extendedToken.token.logoURI,
                                        name: token.extendedToken.token.name ?? token.extendedToken.token.symbol,
                                        symbol: token.extendedToken.token.symbol,
                                        network: token.extendedToken.token.blockchainId ,
                                        value: token.formattedValue,
                                        amount: token.formattedValue)
                                })
                            }
                        }

                    case .error(let string):
                        HStack {
                            Spacer()
                            Text(string)
                            Spacer()
                        }
                    }
                }
                .padding(12)
            }

            Button(action: {
                showSelectTokens = true
            }, label: {
                Text("EDIT")
                    .font(.caption)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(AppStyle.secondaryColor)
                    .cornerRadius(18)

            })
            .offset(CGSize(width: -12.0, height: 12.0))

        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppStyle.thirdColor)
        }
    }
}

struct TokenItemView: View {
    let logoURL: String?
    let name: String
    let symbol: String
    let network: String
    let value: String
    let amount: String

    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: URL(string: logoURL ?? "")) { image in
                image.resizable()
                    .frame(width: 52, height: 52)
                    .cornerRadius(26)
            } placeholder: {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 52, height: 52)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(symbol)
                        .font(.body)
                    VStack {
                        Text(network)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                Text(name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                if !amount.isEmpty {
                    Text(amount)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct TokenSkeletonView: View {
    var body: some View {
        HStack(alignment: .center) {
            Circle()
                .fill(.gray.opacity(0.1))
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.gray.opacity(0.1))
                        .frame(width: 150, height: 16)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.gray.opacity(0.1))
                        .frame(width: 50, height: 16)
                }
                RoundedRectangle(cornerRadius: 6)
                    .fill(.gray.opacity(0.05))
                    .frame(width: 100, height: 16)
            }

            Spacer()

        }
    }
}

#Preview {
    MainView(wallet: .init(title: "Wallet", mnemonic: ""))
}
