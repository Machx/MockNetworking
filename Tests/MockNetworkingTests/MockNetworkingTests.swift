import XCTest
//@testable import MockNetworking
import MockNetworking

final class MockNetworkingTests: XCTestCase {
	
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
		let url = URL(string: "https://wwww.apple.com")!
		let response = HTTPURLResponse(url: url,
									   statusCode: 200,
									   httpVersion: HTTPURLResponse.HTTP_1_1,
									   headerFields: nil)!
		MockURLProtocol.regigster(response: response, for: url)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
