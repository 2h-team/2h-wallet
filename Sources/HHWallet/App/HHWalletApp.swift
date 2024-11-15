// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation
import OSLog
import SwiftUI

let logger: Logger = Logger(subsystem: "hh.app.Wallet", category: "HHWallet")

/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })

public struct RootView : View {

    @StateObject var themeManager = ThemeManager.default

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @StateObject var appState = AppViewModel.shared

    public init() { }

    public var body: some View {
        Group {
            switch appState.state.status {
            case .loading:
                ZStack {
                    themeManager.theme.colors.background
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                .onAppear {
                    appState.trigger(.loadConfig)
                }
            case .loaded:
                if let wallet = appState.state.selectedWallet {
                    MainView(wallet: wallet)
                        .transition(AnyTransition.asymmetric(
                            insertion: .opacity,
                            removal: .opacity)
                        )
                        .environmentObject(appState)
                        .environmentObject(themeManager)
                        #if !SKIP
                        .accentColor(themeManager.theme.colors.accent)
                        #endif
                } else {
                    SelectWalletView(mode: SelectWalletView.Mode.onboarding)
                        .transition(AnyTransition.asymmetric(
                            insertion: .opacity,
                            removal: .opacity)
                        )
                        .environmentObject(appState)
                        .environmentObject(themeManager)
                        #if !SKIP
                        .accentColor(themeManager.theme.colors.accent)
                        #endif
                }

            case .error(let string):
                VStack(spacing: 32) {
                    Spacer()
                    Text(string)
                        .padding()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .font(AppFont.body)

                    HHButton(config: .secondary(text: "Try again")) {
                        appState.trigger(.loadConfig)
                    }
                    Spacer()
                }
                .padding(20)
                .background(themeManager.theme.colors.background)
            }
        }
        .preferredColorScheme(themeManager.theme.colors.colorScheme)
        .onAppear {
            themeManager.changeScheme(colorScheme: colorScheme)
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
