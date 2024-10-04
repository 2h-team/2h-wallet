// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

fileprivate enum Constants {
    static let arrowDown = Image(systemName: "chevron.down")
}

struct SelectTokensView: View {

    enum Mode {
        case many
        case single((Token)->Void)

        var isMany: Bool {
            switch self {
            case .many:
                true
            case .single:
                false
            }
        }
    }

    @StateObject private var viewModel = SelectTokensViewModel()
    @State private var searchText: String = ""

    @State private var showSelectBlockchain: Bool = false

    var mode: Mode = .many

    var body: some View {
        switch mode {
        case .many:
            NavigationStack {
                content
            }
        case .single:
            content
        }
    }

    @ViewBuilder
    var content: some View {
        List {
            Section {
                ForEach(viewModel.state.tokens, id: \.self) { token in
                    switch mode {
                    case .many:
                        tokenView(token: token)
                    case .single:
                        Button(action: {
                            switch mode {
                            case .many:
                                break
                            case .single(let action):
                                action(token.token)
                            }
                        }, label: {
                            tokenView(token: token)
                        })
                    }
                }
            } header: {
                HStack {
                    Button(action: {
                        showSelectBlockchain = true
                    }, label: {
                        HStack {
                            Text((viewModel.state.blockchain?.name ?? "All Blockchains").uppercased())
                                .font(.caption)
                            Constants.arrowDown
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                        }

                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(AppStyle.secondaryColor)
                        .cornerRadius(18)

                    })
                    Spacer()
                }
                .padding(.bottom, 12)
            } footer: {
                if !viewModel.state.isFinished {
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                viewModel.trigger(.load)
                            }
                        Spacer()
                    }
                    .padding()
                } else {
                    if viewModel.state.tokens.isEmpty {
                        HStack {
                            Spacer()
                            Text("Not found")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {

                    }
                    EmptyView()
                }
            }
        }
        #if !SKIP
        .listStyle(.grouped)
        #endif
        #if SKIP
        .searchable(text: $searchText)
        #else
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        #endif
        .navigationTitle("Select tokens")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSelectBlockchain, content: {
            SelectBlockchainsView(selectedBlockchain: viewModel.state.blockchain) { selected in
                showSelectBlockchain = false
                viewModel.trigger(.selectBlockchain(selected))
            }
        })
        .onChange(of: searchText, perform: { value in
            viewModel.trigger(.search(value))
        })
    }

    @ViewBuilder
    func tokenView(token: SelectTokensViewModel.SelectItem) -> some View {
        HStack(spacing: 8) {
            AsyncImage(url: token.token.logoURI?.asURL()) { image in
                image.resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(16)
            } placeholder: {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(token.token.symbol.uppercased())
                        .font(.body.weight(.semibold))
                        .lineLimit(1)

                    if let blockchain = viewModel.state.blockchains[token.token.blockchainId] {
                        VStack {
                            Text(blockchain.shortname)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Text(token.token.name ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)

            }
            .padding(.vertical, 2)
            Spacer()
            if mode.isMany {
                Toggle(isOn: .init(get: {
                    viewModel.state.selectedTokens[token.token.id] ?? false
                }, set: { isOn in
                    viewModel.trigger(.selectToken(token.token, isOn))
                }), label: {
                    EmptyView()
                })
            }

        }
        #if SKIP
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        #endif
        .listRowBackground(AppStyle.thirdColor)
    }

}

#Preview {
    SelectTokensView()
}
