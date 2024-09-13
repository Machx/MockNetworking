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

/// Type that allows you to express a delay in response for a particular request
public enum MockResponseDelay {
	// Specifies that a request should be delayed by a specific time period
	case time(TimeInterval)
	// Specifies that a request should be delayed by a random value in the specified range
	case range(ClosedRange<TimeInterval>)
}

/// Class Responsible for setting up a Mock Network Infrastructure for Network Tests.
public final class MockURLProtocol: URLProtocol {
	
	public enum MockNetworkingErrors: Error {
		/// Unable to retrieve a URL for the given request.
		case unableToRetrieveURLRequest
		/// A mock response for the given url was unable to be retrieved.
		case unableToRetrieveMockResponse
		/// Unable to construct a HTTPURLResponse for a given request.
		case cannotConstructResponse
	}
	
	public static let shared = MockURLProtocol()
	
	//MARK: - Required URLProtocol API's
	
	public override class func canInit(with request: URLRequest) -> Bool {
		guard let url = request.url else { return false }
		return MockResponseStore.shared.contains(url: url)
	}
	
	public override class func canInit(with task: URLSessionTask) -> Bool {
		guard let url = task.currentRequest?.url else { return false }
		return MockResponseStore.shared.contains(url: url)
	}
	
	override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	public override func startLoading() {
		guard let url = request.url else {
			client?.urlProtocol(self, didFailWithError: MockNetworkingErrors.unableToRetrieveURLRequest)
			return
		}
		guard let mockResponse = MockResponseStore.shared[url] else {
			client?.urlProtocol(self, didFailWithError: MockNetworkingErrors.unableToRetrieveMockResponse)
			return
		}
		
		guard let httpStatus = mockResponse.response?.statusCode,
			  let httpHeaderFields = mockResponse.response?.allHeaderFields as? [String: String],
			  let httpResponse = HTTPURLResponse(url: url,
												 statusCode: httpStatus,
												 httpVersion: mockResponse.httpVersion,
												 headerFields: httpHeaderFields) else {
			client?.urlProtocol(self, didFailWithError: MockNetworkingErrors.cannotConstructResponse)
			return
		}
		
		if let delay = mockResponse.delay {
			switch delay {
			case .time(let time):
				Thread.sleep(forTimeInterval: time)
			case .range(let range):
				let randomTimeInRange = Double.random(in: range)
				Thread.sleep(forTimeInterval: randomTimeInRange)
			}
		}
		
		client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
		
		if let data = mockResponse.bodyData {
			client?.urlProtocol(self, didLoad: data)
		}
		
		if let error = mockResponse.error {
			client?.urlProtocol(self, didFailWithError: error)
		} else {
			client?.urlProtocolDidFinishLoading(self)
		}
	}
	
	public override func stopLoading() {
		//
	}
	
	//MARK: - Registration API's
	
	private static var _isRegistered = false
	
	/// Registers MockURLProtocol and sets the values that should be responded to the given URL.
	/// - Parameters:
	///   - response: An object that contains the values that should be responded with to the request for the URL.
	///   - url: The URL that should be responded to.
	public static func registerMock(response: MockPropertyResponse, for url: URL) {
		if !_isRegistered {
			URLProtocol.registerClass(MockURLProtocol.self)
			_isRegistered = true
		}
		MockResponseStore.shared[url] = response
	}
	
	/// Registers MockURLProtocol and sets the values that should be responded to the given URL in the response object.
	/// - Parameters:
	///   - response: A HTTPURLResponse object containing the values that should be responded with to the request for the URL.
	///   - url: The URL that should be responded to.
	///   - delay: An optional parameter that specifies a time value to delay the response to a given url.
	public static func register(response: HTTPURLResponse,
								for url: URL,
								withDelay delay: MockResponseDelay? = nil) {
		if !_isRegistered {
			URLProtocol.registerClass(MockURLProtocol.self)
			_isRegistered = true
		}
		let headers = response.allStringHTTPHeaders() ?? [:]
		let mockResponse = MockPropertyResponse(url: url,
												status: response.statusCode,
												httpVersion: HTTPURLResponse.HTTP_1_1,
												headerFields: headers,
												body: nil,
												error: nil,
												delay: delay)
		MockResponseStore.shared[url] = mockResponse
	}
	
	/// Unregisters MockURLProtocol from handling responses to network requests.
	public static func unregister() {
		guard _isRegistered else { return }
		URLProtocol.unregisterClass(MockURLProtocol.self)
		_isRegistered = false
	}
	
	//MARK: - Other API's
	
	/// Clears all stored responses to network requests, after this MockURLProtocol will no respond to any more requests until a response is registered.
	public static func clearAllResponses() {
		MockResponseStore.shared.removeAllReponses()
	}
	
	/// Clears a response to a specific URL
	///
	/// Once a response is cleared, MockURLProtocol will not respond to a given URL until another
	/// response is registered.
	///
	/// - Parameter url: A URL who's corresponding response should be cleared.
	/// - Returns: A value of true if the response was removed, false otherwise.
	@discardableResult
	public static func clearResponse(for url: URL) -> Bool {
		return MockResponseStore.shared.removeResponse(for: url)
	}
}
