import XCTest
@testable import MockNetworking

final class MockNetworkingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
		XCTAssertEqual(MockNetworking().major, 0)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
