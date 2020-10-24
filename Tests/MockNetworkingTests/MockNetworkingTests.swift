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
import MockNetworking

final class MockNetworkingTests: XCTestCase {
	
    func testBasicMockResponse() throws {
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let response = try XCTUnwrap(HTTPURLResponse(url: url,
									   statusCode: 200,
									   httpVersion: HTTPURLResponse.HTTP_1_1,
									   headerFields: nil))
		
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
	
	func testBasicMockResponseWithMockType() throws {
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let mockResponse = MockPropertyResponse(url: url,
												status: 200,
												headerFields: [:])
		
		MockURLProtocol.regigsterMock(response: mockResponse, for: url)
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
		XCTAssertGreaterThanOrEqual(result, 1.0)
	}
	
	func testDelayRange() throws {
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
		XCTAssertGreaterThanOrEqual(result, 1.0)
	}
	
	func testRemoveResponse() throws {
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let response = try XCTUnwrap(HTTPURLResponse(url: url,
													 statusCode: 200,
													 httpVersion: HTTPURLResponse.HTTP_1_1,
													 headerFields: nil))
		
		MockURLProtocol.register(response: response,
								 for: url,
								 withDelay: .range(1...2))
		defer {
			MockURLProtocol.unregister()
		}
		
		let request = URLRequest(url: url)
		XCTAssertTrue(MockURLProtocol.canInit(with: request))
		
		MockURLProtocol.clearResponse(for: url)
		XCTAssertFalse(MockURLProtocol.canInit(with: request))
	}
	
	func testHeaders() throws {
		let originalHeaders = [
			"Thing1" : "Thing2"
		]
		
		let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
		let response = try XCTUnwrap(HTTPURLResponse(url: url,
													 statusCode: 200,
													 httpVersion: HTTPURLResponse.HTTP_1_1,
													 headerFields: originalHeaders))
		
		MockURLProtocol.register(response: response,
								 for: url,
								 withDelay: .range(1...2))
		defer {
			MockURLProtocol.unregister()
		}
		
		let expectation = XCTestExpectation()
		var headers:[AnyHashable: Any] = [:]
		URLSession.sessionWith(.ephemeral, delegate: nil).downloadTask(with: url) { (_, response, _) in
			if let localResponse = response,
			   let httpResponse = localResponse as? HTTPURLResponse {
				headers = httpResponse.allHeaderFields
			}
			expectation.fulfill()
		}.resume()
		
		wait(for: [expectation], timeout: 2.0)
		
		if let receivedHeaders = headers as? [String:String] {
			XCTAssertEqual(receivedHeaders, originalHeaders)
		} else {
			XCTFail("not equatable")
		}
	}
	
	func testErrorResponse() throws {
		let url = try XCTUnwrap(URL(string: "https://www.apple.com"))
		let error = NSError(domain: "com.MockNetworking.UnitTests",
							code: 200,
							userInfo: [ "Key1":"Value1"])
		let mockResponse = MockPropertyResponse(url: url,
												status: 200, httpVersion: HTTPURLResponse.HTTP_1_1,
												headerFields: [:],
												error: error)
		
		MockURLProtocol.regigsterMock(response: mockResponse, for: url)
		defer {
			MockURLProtocol.unregister()
		}
		
		var receivedError: NSError?
		let request = URLRequest(url: url)
		let expectation = XCTestExpectation()
		URLSession.sessionWith(.ephemeral).downloadTask(with: request) { (url, _, error) in
			receivedError = error as NSError?
			expectation.fulfill()
		}.resume()
		
		wait(for: [expectation], timeout: 2.0)
		
		XCTAssertNotNil(receivedError)
		XCTAssertEqual(receivedError?.code, error.code)
		XCTAssertEqual(receivedError?.domain, error.domain)
	}
	
	func testBodyData() throws {
		let url = try XCTUnwrap(URL(string: "https://www.apple.com"))
		
		let originalString = "Hello World"
		let originalData = originalString.data(using: .utf8)
		
		let mockResponse = MockPropertyResponse(url: url,
												status: 200,
												headerFields: [:],
												body: originalData)
		
		MockURLProtocol.regigsterMock(response: mockResponse, for: url)
		defer {
			MockURLProtocol.unregister()
		}
		
		let expectation = XCTestExpectation()
		let request = URLRequest(url: url)
		var receivedData: Data?
		URLSession.sessionWith(.ephemeral).dataTask(with: request) { (data, _, _) in
			receivedData = data
			expectation.fulfill()
		}.resume()
		
		wait(for: [expectation], timeout: 2.0)
		
		let data = try XCTUnwrap(receivedData)
		XCTAssertEqual(data, originalData)
	}

    static var allTests = [
        ("testBasicMockResponse", testBasicMockResponse),
		("testBasicMockResponseWithMockType", testBasicMockResponseWithMockType),
		("testDelay", testDelay),
		("testDelayRange", testDelayRange),
		("testRemoveResponse", testRemoveResponse),
		("testHeaders", testHeaders),
		("testErrorResponse", testErrorResponse),
    ]
}
