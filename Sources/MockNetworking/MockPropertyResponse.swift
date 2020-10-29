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
	public typealias HTTPStatusCode = Int // Because Apple uses Int
	
	var response: HTTPURLResponse?
	var error: Error?
	var httpVersion: String = HTTPURLResponse.HTTP_1_1
	var bodyData: Data?
	var delay: MockResponseDelay?
	
	/// Designated initializer for MockPropertyResponse.
	/// - Parameters:
	///   - url: The URL this response should be for.
	///   - status: The HTTP Status code that should be used to respond to the Request for the URL.
	///   - version: A HTTP Version that should be used in the response.
	///   - headers: The Headers that should be included in the response.
	///   - body: The Body Data that should be included in the response.
	///   - requestError: The Error that should be included.
	///   - responseDelay: An optional parameter that can be set to induce an artificial delay.
	public init(url: URL,
		 status: HTTPStatusCode = 200,
		 httpVersion version: String = HTTPURLResponse.HTTP_1_1,
		 headerFields headers: [String: String],
		 body: Data? = nil,
		 error requestError: Error? = nil,
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
	
	var headers: [String:String]? {
		guard let localHeaders = response?.allHeaderFields,
			  let stringHeaders = localHeaders as? [String:String] else { return nil }
		return stringHeaders
	}
	
	var url: URL? {
		return response?.url
	}
}
