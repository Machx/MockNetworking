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

public final class MockPropertyResponse {
	typealias HTTPStatusCode = Int // Because Apple uses Int
	
	var statusCode: HTTPStatusCode
	var httpVersion: String = HTTPURLResponse.HTTP_1_1
	var headerFields = [String: String]()
	var bodyData: Data?
	var error: Error?
	
	init(status: HTTPStatusCode = 200,
		 httpVersion version: String = HTTPURLResponse.HTTP_1_1,
		 headerFields headers: [String: String],
		 body: Data?,
		 error requestError: Error?) {
		statusCode = status
		httpVersion = version
		headerFields =  headers
		bodyData = body
		error = requestError
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
	
	public static let shared = MockURLProtocol()
	
	private enum MockURLRequestKeys: String {
		case data = "Data"
		case error = "Error"
		case status = "StatusCode"
		case headers = "HeaderFields"
	}
	
	//MARK: - Required URLProtocol API's
	
	public override class func canInit(with request: URLRequest) -> Bool {
		guard let url = request.url else { return false }
		return URLPropertyStore.shared.contains(url: url)
	}
	
	public override class func canInit(with task: URLSessionTask) -> Bool {
		guard let url = task.currentRequest?.url else { return false }
		return URLPropertyStore.shared.contains(url: url)
	}
	
	public override func startLoading() {
		guard let url = request.url else { return }
		guard let response = MockURLProtocol.response(for: url) else { return }
		
		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
	}
	
	public override func stopLoading() {
		//
	}
	
	//MARK: - Registration API's
	
	private static var isRegistered = false
	
	public static func regigster(response: HTTPURLResponse, for url: URL) {
		if !isRegistered {
			URLProtocol.registerClass(MockURLProtocol.self)
		}
		responses[url] = response
	}
	
	public static func unregister() {
		guard isRegistered else { return }
		URLProtocol.unregisterClass(MockURLProtocol.self)
		isRegistered = false
	}
}
