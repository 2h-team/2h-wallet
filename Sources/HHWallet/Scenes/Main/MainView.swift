// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct MainView: View {

    fileprivate enum Constants {
        static let arrowDown = "chevron.down"
    }

    @EnvironmentObject 
    var appState: AppViewModel

    @EnvironmentObject
    var themeManager: ThemeManager

    @StateObject 
    var viewModel: MainViewModel

    @State 
    private var showSelectWallet: Bool = false

    @State
    private var showSelectCurrency: Bool = false

    @State
    private var showSelectTokens: Bool = false

    @State
    private var showReceive: Bool = false

    @State
    private var showSend: Bool = false

    init(wallet: Wallet) {
        self._viewModel = StateObject(wrappedValue: MainViewModel(wallet: wallet))
    }

    var body: some View {

        ZStack(alignment: .bottom) {
            content()
                .refreshable {
                    viewModel.trigger(.load)
                }

            // tabbar()
        }
        .onAppear {
            viewModel.trigger(.load)
        }
        .sheet(isPresented: $showSelectWallet, content: {
            SelectWalletView(mode: SelectWalletView.Mode.onboarding)
                .background(themeManager.theme.colors.background)
        })
        .sheet(isPresented: $showReceive, content: {
            ReceiveView(mode: ReceiveView.Mode.default)
                .environmentObject(appState)
        })
        .sheet(isPresented: $showSend, content: {
            TransferView(mode: .default)
                .environmentObject(appState)
        })
        .sheet(isPresented: $showSelectTokens, onDismiss: {
            viewModel.trigger(.load)
        }, content: {
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
    private func tabbar() -> some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 4) {
                    ForEach(0..<10) { _ in
                        Button {

                        } label: {
                            Text("App 1")
                        }
                        .padding(20)
                        .background(.gray)
                    }
                }
            }
            .frame(height: 80)
        }
        .padding(16)
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
                        .font(AppFont.subheadline)
                        .foregroundColor(themeManager.theme.colors.accent)
                }
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 0, trailing: 14))
                HStack {
                    Spacer()
                    switch viewModel.state.status {
                    case .loading, .error:
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.gray.opacity(0.1))
                            .frame(width: 120, height: 58)
                    case .loaded:
                        Text(viewModel.state.estimateBalance)
                            .font(AppFont.custom(.light, size: 52))
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 28, trailing: 14))
            }

            HHButton(config: .secondary(text: viewModel.state.currency, size: .small, fitContent: true)) {
                showSelectCurrency = true
            }
            .offset(CGSize(width: -12.0, height: 12.0))

        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.theme.colors.thirdBackground)
        }
    }

    @ViewBuilder
    private func selectWalletButton() -> some View {
        HHButton(
            config: .secondary(
                text: viewModel.state.currentWallet.title,
                imageName: Constants.arrowDown,
                isRtl: true,
                imageSize: 12.0
            )
        ) {
            showSelectWallet = true
        }
    }

    @ViewBuilder
    private func settingsButton() -> some View {
        HHButton(config: .secondary(text: nil, imageName: "gearshape.fill")) {
            debugPrint("Click")
        }
    }

    @ViewBuilder
    private func receiveButton() -> some View {
        HHButton(config: .secondary(text: "Receive")) {
            showReceive = true
        }
    }

    @ViewBuilder
    private func sendButton() -> some View {
        HHButton(config: .secondary(text: "Send")) {
            showSend = true
        }
    }

    @ViewBuilder
    private func buyButton() -> some View {
        HHButton(config: .secondary(text: "Buy")) {
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
                        .font(AppFont.subheadline)
                        .foregroundColor(themeManager.theme.colors.accent)
                }
                .padding(EdgeInsets(top: 12, leading: 14, bottom: 0, trailing: 14))

                VStack(spacing: 24) {
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
                                    .font(AppFont.subheadline)
                                    .foregroundColor(themeManager.theme.colors.accent)
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
                                        amount: token.formattedValue,
                                        price: token.formattedPrice,
                                        change24h: token.extendedToken.change24h
                                    )
                                    .environmentObject(themeManager)
                                })
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            }
                        }

                    case .error(let string):
                        HStack {
                            Spacer()
                            Text(string)
                                .font(AppFont.body)
                            Spacer()
                        }
                    }
                }
                .padding(.top, 12)
            }

            HHButton(config: .secondary(text: "Edit", size: .small, fitContent: true)) {
                showSelectTokens = true
            }
            .offset(CGSize(width: -12.0, height: 12.0))
        }
        .padding(.bottom, 24)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.theme.colors.thirdBackground)
        }
    }
}

struct TokenItemView: View {

    @EnvironmentObject
    var themeManager: ThemeManager

    let logoURL: String?
    var logoSize: CGFloat = 38
    let name: String
    let symbol: String
    let network: String
    let value: String
    let amount: String
    let price: String
    let change24h: Double?

    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: URL(string: logoURL ?? "")) { image in
                image.resizable()
                    .frame(width: logoSize, height: logoSize)
                    .cornerRadius(logoSize / 2)
            } placeholder: {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: logoSize, height: logoSize)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(symbol.uppercased())
                        .font(AppFont.bodyBold)
                        .foregroundColor(themeManager.theme.colors.text)
                    if !network.isEmpty {
                        VStack {
                            Text(network)
                                .font(AppFont.captionMedium)
                                .foregroundColor(themeManager.theme.colors.secondaryText)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                HStack(spacing: 8) {
                    if !price.isEmpty {
                        Text(price)
                            .font(AppFont.captionMedium)
                            .foregroundColor(themeManager.theme.colors.secondaryText)
                    }

                    if let change24h = change24h {
                        Text(change24h.asChangePercent())
                            .font(AppFont.captionMedium)
                            .foregroundColor(change24h >= 0 ? themeManager.theme.colors.successText : themeManager.theme.colors.failText)
                    }
                }

            }

            if !value.isEmpty {
                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(value)
                        .font(AppFont.bodyBold)
                        .foregroundColor(themeManager.theme.colors.text)
                    if !amount.isEmpty {
                        Text(amount)
                            .font(AppFont.caption)
                            .foregroundColor(themeManager.theme.colors.secondaryText)
                    }
                }
            }

        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}

struct TokenSkeletonView: View {
    var body: some View {
        HStack(alignment: .center) {
            Circle()
                .fill(.gray.opacity(0.1))
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 6) {
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
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}

#Preview {
    MainView(wallet: .init(title: "Wallet", mnemonic: "123"))
}
