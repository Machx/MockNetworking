/// Copyright 2020 Colin Wheeler
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///	http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import XCTest
//@testable import MockNetworking
import MockNetworking

final class MockNetworkingTests: XCTestCase {
	
    func testBasicMockResponse() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let response = HTTPURLResponse(url: url,
									   statusCode: 200,
									   httpVersion: HTTPURLResponse.HTTP_1_1,
									   headerFields: nil)!
		
		MockURLProtocol.register(response: response, for: url)
		defer {
			MockURLProtocol.unregister()
		}
		
		var receivedURL: URL?
		var receivedResponse: URLResponse?
		var receivedError: Error?
		
		let expectation = XCTestExpectation()
		URLSession.sessionWith(.ephemeral, delegate: nil).downloadTask(with: url) { (url, response, error) in
			receivedURL = response?.url
			receivedResponse = response
			receivedError = error
			expectation.fulfill()
		}.resume()
		
		wait(for: [expectation], timeout: 5.0)
		
		XCTAssertEqual(url, receivedURL)
		XCTAssertNotNil(receivedResponse)
		XCTAssertNil(receivedError)
    }
	
	func testDelay() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct
		// results.
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let response = try XCTUnwrap(HTTPURLResponse(url: url,
													 statusCode: 200,
													 httpVersion: HTTPURLResponse.HTTP_1_1,
													 headerFields: nil))
		
		MockURLProtocol.register(response: response, for: url, withDelay: .time(1.0))
		defer {
			MockURLProtocol.unregister()
		}
		
		let expectation = XCTestExpectation()
		let start = CFAbsoluteTimeGetCurrent()
		var end: Double = 0
		URLSession.sessionWith(.ephemeral, delegate: nil).downloadTask(with: url) { (_, _, _) in
			expectation.fulfill()
			end = CFAbsoluteTimeGetCurrent()
		}.resume()
		
		wait(for: [expectation], timeout: 5.0)
		
		let result = end - start
		XCTAssertGreaterThan(result, 1.0)
	}
	
	func testDelayRange() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct
		// results.
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let response = try XCTUnwrap(HTTPURLResponse(url: url,
													 statusCode: 200,
													 httpVersion: HTTPURLResponse.HTTP_1_1,
													 headerFields: nil))
		
		MockURLProtocol.register(response: response, for: url, withDelay: .range(1...2))
		defer {
			MockURLProtocol.unregister()
		}
		
		let expectation = XCTestExpectation()
		let start = CFAbsoluteTimeGetCurrent()
		var end: Double = 0
		URLSession.sessionWith(.ephemeral, delegate: nil).downloadTask(with: url) { (_, _, _) in
			expectation.fulfill()
			end = CFAbsoluteTimeGetCurrent()
		}.resume()
		
		wait(for: [expectation], timeout: 5.0)
		
		let result = end - start
		XCTAssertGreaterThan(result, 1.0)
	}

    static var allTests = [
        ("testBasicMockResponse", testBasicMockResponse),
		("testDelay", testDelay),
		("testDelayRange", testDelayRange),
    ]
}
