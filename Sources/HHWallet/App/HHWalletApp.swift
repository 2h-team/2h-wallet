// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import OSLog
import SwiftUI

let logger: Logger = Logger(subsystem: "hh.app.Wallet", category: "HHWallet")

/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })

let appState = AppViewModel()

public struct RootView : View {

    @StateObject var viewModel: AppViewModel = appState

    public init() {

    }

    public var body: some View {
        switch viewModel.state.status {
        case .loading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .onAppear {
                viewModel.trigger(.loadConfig)
            }
        case .loaded:
            if viewModel.state.walletSelected {
                MainView()
                    .transition(AnyTransition.asymmetric(
                        insertion: .opacity,
                        removal: .opacity)
                    )
            } else {
                SelectWalletView(mode: .onboarding)
                    .transition(AnyTransition.asymmetric(
                        insertion: .opacity,
                        removal: .opacity)
                    )
            }

        case .error(let string):
            VStack(spacing: 32) {
                Spacer()
                Text(string)
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)

                ButtonView(text: "Try again", image: nil, style: .secondary, action: {
                    viewModel.trigger(.loadConfig)
                })
                Spacer()
            }
        }




    }
}

#if !SKIP
public protocol HHWalletApp : App {
}

/// The entry point to the HHWallet app.
/// The concrete implementation is in the HHWalletApp module.
public extension HHWalletApp {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#endif
