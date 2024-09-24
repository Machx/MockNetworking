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

import Foundation
@testable import MockNetworking
import Testing

enum MockNetworkingTestError: Error {
	case couldNotUnwrapPreparedResponse
	case couldNotUnwrapVariable
}

@Suite("Mock Networking Tests")
struct MockNetworkingTests {
	@Test("Test Basic Mock Response")
	func testBasicMockResponse() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
			  let response = HTTPURLResponse(url: url,
											 statusCode: 200,
											 httpVersion: HTTPURLResponse.HTTP_1_1,
											 headerFields: nil) else { throw MockNetworkingTestError.couldNotUnwrapPreparedResponse }

		MockURLProtocol.register(response: response, for: url)
		defer { MockURLProtocol.unregister() }

		var receivedURL: URL?
		var receivedResponse: URLResponse?
		var receivedError: Error?

		do {
			let (_,taskResponse) =  try await URLSession.sessionWith(.ephemeral).data(from: url)
			receivedURL = response.url
			receivedResponse = taskResponse
		} catch {
			receivedError = error
		}

		#expect(url == receivedURL)
		#expect(receivedResponse != nil)
		#expect(receivedError == nil)
	}

	@Test("Test Basic Mock Response with Mock Type")
	func testBasicMockResponseWithMockType() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com") else {
			throw MockNetworkingTestError.couldNotUnwrapVariable
		}
		let mockResponse = MockPropertyResponse(url: url,
												status: 200,
												headerFields: [:])

		MockURLProtocol.registerMock(response: mockResponse, for: url)
		defer { MockURLProtocol.unregister() }

		var receivedURL: URL?
		var receivedResponse: URLResponse?
		var receivedError: Error?
		do {
			let (_, taskResponse) = try await URLSession.sessionWith(.ephemeral).data(from: url)
			receivedURL = taskResponse.url
			receivedResponse = taskResponse
		} catch {
			receivedError = error
		}

		#expect(url == receivedURL)
		#expect(receivedResponse != nil)
		#expect(receivedError == nil)
	}

	@Test("Test Delay API")
	func testDelay() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
			  let response = HTTPURLResponse(url: url,
											 statusCode: 200,
											 httpVersion: HTTPURLResponse.HTTP_1_1,
											 headerFields: nil) else {
			throw MockNetworkingTestError.couldNotUnwrapPreparedResponse
		}

		MockURLProtocol.register(response: response, for: url, withDelay: .time(1.0))
		defer { MockURLProtocol.unregister() }

		let start = CFAbsoluteTimeGetCurrent()
		let (_,_) = try await URLSession.sessionWith(.ephemeral).data(from: url)
		let end = CFAbsoluteTimeGetCurrent()

		let result = end - start
		#expect(result >= 1.0)
	}

	@Test("Test Delay Range")
	func testDelayRange() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
			  let response = HTTPURLResponse(url: url,
											 statusCode: 200,
											 httpVersion: HTTPURLResponse.HTTP_1_1,
											 headerFields: nil) else {
			throw MockNetworkingTestError.couldNotUnwrapPreparedResponse
		}

		MockURLProtocol.register(response: response, for: url, withDelay: .range(1...2))
		defer { MockURLProtocol.unregister() }

		let start = CFAbsoluteTimeGetCurrent()
		let (_,_) = try await URLSession.sessionWith(.ephemeral).data(from: url)
		let end = CFAbsoluteTimeGetCurrent()
		#expect((end - start) >= 1.0)
	}

	@Test("Test Remove Response")
	func testRemoveResponse() throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
			  let response = HTTPURLResponse(url: url,
											 statusCode: 200,
											 httpVersion: HTTPURLResponse.HTTP_1_1,
											 headerFields: nil) else {
			throw MockNetworkingTestError.couldNotUnwrapPreparedResponse
		}

		MockURLProtocol.register(response: response,
								 for: url,
								 withDelay: .range(1...2))
		defer { MockURLProtocol.unregister() }

		let request = URLRequest(url: url)
		#expect(MockURLProtocol.canInit(with: request) == true)

		MockURLProtocol.clearResponse(for: url)
		#expect(MockURLProtocol.canInit(with: request) == false)
	}

	@Test("Test Headers")
	func testHeaders() async throws {
		let originalHeaders = [
			"Thing1" : "Thing2"
		]

		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
			  let response = HTTPURLResponse(url: url,
											 statusCode: 200,
											 httpVersion: HTTPURLResponse.HTTP_1_1,
											 headerFields: originalHeaders) else {
			throw MockNetworkingTestError.couldNotUnwrapPreparedResponse
		}

		MockURLProtocol.register(response: response,
								 for: url,
								 withDelay: .range(1...2))
		defer { MockURLProtocol.unregister() }

		var headers = [AnyHashable: Any]()
		let (_,taskResponse) = try await URLSession.sessionWith(.ephemeral).data(from: url)
		if let httpResponse = taskResponse as? HTTPURLResponse {
			headers = httpResponse.allHeaderFields
		}

		struct CouldNotCompareHeadersError: Error {}
		guard let receivedHeaders = headers as? [String:String] else { throw CouldNotCompareHeadersError() }
		#expect(receivedHeaders == originalHeaders)
	}

	@Test("Test Error Response")
	func testErrorResponse() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com") else {
			throw MockNetworkingTestError.couldNotUnwrapVariable
		}
		let error = NSError(domain: "com.MockNetworking.UnitTests",
							code: 200,
							userInfo: [ "Key1":"Value1"])
		let mockResponse = MockPropertyResponse(url: url,
												status: 200, httpVersion: HTTPURLResponse.HTTP_1_1,
												headerFields: [:],
												error: error)

		MockURLProtocol.registerMock(response: mockResponse, for: url)
		defer { MockURLProtocol.unregister() }

		var receivedError: NSError?
		let request = URLRequest(url: url)
		do {
			let (_,_) = try await URLSession.sessionWith(.ephemeral).data(for: request)
		} catch {
			receivedError = error as NSError
		}

		#expect(receivedError?.code == error.code)
		#expect(receivedError?.domain == error.domain)
	}

	@Test("Test Body Data")
	func testBodyData() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com") else {
			throw MockNetworkingTestError.couldNotUnwrapPreparedResponse
		}

		let originalString = "Hello World"
		let originalData = originalString.data(using: .utf8)

		let mockResponse = MockPropertyResponse(url: url,
												status: 200,
												headerFields: [:],
												body: originalData)

		MockURLProtocol.registerMock(response: mockResponse, for: url)
		defer { MockURLProtocol.unregister() }

		let request = URLRequest(url: url)
		let (data, _) = try await URLSession.sessionWith(.ephemeral).data(for: request)
		#expect(data == originalData)
	}

	@Test("Test HTTP Response")
	func testHTTPResponse() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
			  let response = HTTPURLResponse(url: url,
											 statusCode: 200,
											 httpVersion: HTTPURLResponse.HTTP_1_1,
											 headerFields: ["thing180":"thing2"]) else {
			throw MockNetworkingTestError.couldNotUnwrapVariable
		}

		MockURLProtocol.register(response: response, for: url)
		defer { MockURLProtocol.unregister() }

		let (_, receivedResponse) = try await URLSession.sessionWith(.ephemeral).data(from: url)
		guard let receivedHTTPResponse = receivedResponse as? HTTPURLResponse else {
			throw MockNetworkingTestError.couldNotUnwrapVariable
		}
		// We can't compare the HTTPURLResponse we get back directly with an
		// XCTAssertEqual(response,otherResponse) because it considers the text/mime type
		// in equality, which ours will be nil and the received will be "text/plain"
		#expect(response.url == receivedHTTPResponse.url)
		#expect(response.statusCode == receivedHTTPResponse.statusCode)
		#expect(response.allStringHTTPHeaders() == receivedHTTPResponse.allStringHTTPHeaders())

		let header = receivedHTTPResponse.allHeaderFields["thing180"] as? String
		#expect(header == "thing2")
	}

	@Test("Test Response Equality Functions")
	func testResponseEquality() async throws {
		guard let url = URL(string: "https://www.\(Int.random(in: 1...10000000)).com"),
		let httpResponse = HTTPURLResponse(url: url,
										   statusCode: 200,
										   httpVersion: "HTTP/1.1",
										   headerFields: [
											"Test" : "test"
										   ]) else {
											   throw MockNetworkingTestError.couldNotUnwrapVariable
										   }

		let urlResponse = httpResponse as URLResponse
		#expect(httpResponse.isBasicallyEqual(to: urlResponse))

		guard let anotherEqualHTTPResponse = HTTPURLResponse(url: url,
															 statusCode: 200,
															 httpVersion: "HTTP/1.1",
															 headerFields: [
																"Test" : "test"
															 ]) else {
			throw MockNetworkingTestError.couldNotUnwrapVariable
		}
		#expect(anotherEqualHTTPResponse.isBasicallyEqual(to: httpResponse))

		guard let anUnqualResponse = HTTPURLResponse(url: url,
													 statusCode: 201,
													 httpVersion: "HTTP/1.2",
													 headerFields: [
														"Test" : "test222222"
													 ]) else {
			throw MockNetworkingTestError.couldNotUnwrapVariable
		}

		#expect(anUnqualResponse.isBasicallyEqual(to: httpResponse) == false)
	}

	@Test("Test Header Response getter")
	func testResponseHeaderGetter() async throws {
		let mockResponse = MockPropertyResponse(url: URL(string: "https://www.apple.com")!,
												status: 200,
												headerFields: [:])

		let expectedHeaders = [String:String]()
		#expect(mockResponse.headers == expectedHeaders)
	}

	@Test("Test Session with Convenience API and nil parameter")
	func testSessionWithNil() async throws {
		let session = URLSession.sessionWith(nil)
		#expect(session != nil)
	}
}
