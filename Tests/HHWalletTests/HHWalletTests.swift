import XCTest
import OSLog
import Foundation
@testable import HHWallet

let logger: Logger = Logger(subsystem: "HHWallet", category: "Tests")

@available(macOS 13, *)
final class HHWalletTests: XCTestCase {
    func testHHWallet() throws {
        logger.log("running testHHWallet")
        XCTAssertEqual(1 + 2, 3, "basic test")
        
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("HHWallet", testData.testModuleName)
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}