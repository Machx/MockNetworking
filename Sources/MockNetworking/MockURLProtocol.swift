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

public enum MockResponseDelay {
	case time(TimeInterval)
	case range(ClosedRange<TimeInterval>)
}

public final class MockPropertyResponse {
	typealias HTTPStatusCode = Int // Because Apple uses Int
	
	var response: HTTPURLResponse?
	var body: Data?
	var error: Error?
	var httpVersion: String = HTTPURLResponse.HTTP_1_1
	var bodyData: Data?
	var delay: MockResponseDelay?
	
	init(url: URL,
		 status: HTTPStatusCode = 200,
		 httpVersion version: String = HTTPURLResponse.HTTP_1_1,
		 headerFields headers: [String: String],
		 body: Data?,
		 error requestError: Error?) {
		 delay responseDelay: MockResponseDelay? = nil) {
		
		response = HTTPURLResponse(url: url,
								   statusCode: status,
								   httpVersion: version,
								   headerFields: headers)
		httpVersion = version
		bodyData = body
		error = requestError
		delay = responseDelay
	}
}

fileprivate final class URLPropertyStore {
	fileprivate static let shared = URLPropertyStore()
	
	private var storedResponses = [URL: MockPropertyResponse]()
	
	init() {
	}
	
	subscript(url: URL) -> MockPropertyResponse? {
		get {
			return storedResponses[url]
		}
		
		set {
			storedResponses[url] = newValue
		}
	}
	
	func contains(url: URL) -> Bool {
		return storedResponses.keys.contains(url)
	}
}

public final class MockURLProtocol: URLProtocol {
	
	public enum MockNetworkingErrors: Error {
		case unableToRetrieveURLRequest
		case unableToRetrieveMockResponse
		case cannotConstructResponse
	}
	
	public static let shared = MockURLProtocol()
	
	//MARK: - Required URLProtocol API's
	
	public override class func canInit(with request: URLRequest) -> Bool {
		guard let url = request.url else { return false }
		return URLPropertyStore.shared.contains(url: url)
	}
	
	public override class func canInit(with task: URLSessionTask) -> Bool {
		guard let url = task.currentRequest?.url else { return false }
		return URLPropertyStore.shared.contains(url: url)
	}
	
	override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	public override func startLoading() {
		guard let url = request.url else {
			client?.urlProtocol(self, didFailWithError: MockNetworkingErrors.unableToRetrieveURLRequest)
			return
		}
		guard let mockResponse = URLPropertyStore.shared[url] else {
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
	
	public static func regigsterMock(response: MockPropertyResponse, for url: URL) {
		if !_isRegistered {
			URLProtocol.registerClass(MockURLProtocol.self)
			_isRegistered = true
		}
		URLPropertyStore.shared[url] = response
	}
	
	public static func register(response: HTTPURLResponse, for url: URL) {
		if !_isRegistered {
			URLProtocol.registerClass(MockURLProtocol.self)
			_isRegistered = true
		}
		let httpResponse = MockPropertyResponse(url: url,
												status: response.statusCode,
												httpVersion: HTTPURLResponse.HTTP_1_1,
												headerFields: [:],
												body: nil,
												error: nil)
		URLPropertyStore.shared[url] = httpResponse
	}
	
	public static func unregister() {
		guard _isRegistered else { return }
		URLProtocol.unregisterClass(MockURLProtocol.self)
		_isRegistered = false
	}
}
