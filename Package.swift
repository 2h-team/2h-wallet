// swift-tools-version: 5.9
// This is a Skip (https://skip.tools) package,
// containing a Swift Package Manager project
// that will use the Skip build plugin to transpile the
// Swift Package, Sources, and Tests into an
// Android Gradle Project with Kotlin sources and JUnit tests.
import PackageDescription
import Foundation

// Set SKIP_ZERO=1 to build without Skip libraries
let zero = ProcessInfo.processInfo.environment["SKIP_ZERO"] != nil
let skipstone = !zero ? [Target.PluginUsage.plugin(name: "skipstone", package: "skip")] : []

let package = Package(
    name: "hh-wallet",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "HHWalletApp", type: .dynamic, targets: ["HHWallet"]),

    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.8.33"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "0.0.0"),
        .package(url: "https://source.skip.tools/skip-keychain.git", from: "0.0.0"),
        .package(url: "https://github.com/trustwallet/wallet-core", branch: "master")
    ],
    targets: [
        .target(name: "HHWallet", dependencies: (zero ? [] : [
            .product(name: "SkipUI", package: "skip-ui"),
            .product(name: "SkipKeychain", package: "skip-keychain"),
            .product(name: "WalletCore", package: "wallet-core"),
            .product(name: "SwiftProtobuf", package: "wallet-core")
        ]
        ),
                resources: [.process("Resources")], plugins: skipstone
        ),
        .testTarget(name: "HHWalletTests", dependencies: ["HHWallet"] + (zero ? [] : [.product(name: "SkipTest", package: "skip")]), resources: [.process("Resources")], plugins: skipstone),
    ]
)
