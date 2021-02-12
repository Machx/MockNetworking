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

public extension HTTPURLResponse {
	static let HTTP_1_1 = "HTTP/1.1"
	
	/// Returns all the String value headers if the header fields can be returned as that
	///
	/// This casts the headers to string values and then returns the string header values
	/// - Returns: The headers as string values, otherwise nil.
	func allStringHTTPHeaders() -> [String:String]? {
		let headers = self.allHeaderFields.getStringHeaders()
		guard !headers.isEmpty else { return nil }
		return headers
	}
	
	
	/// Tests HTTPURLResponse for equality for Unit Testing Purposes.
	///
	/// This version of equality tests the url, status code and headers for equality.
	/// - Parameter otherResponse: The other HTTPURLResponse to test for equality.
	/// - Returns: True if both responses have the same status code, url, and headers.
	func isBasicallyEqual(to otherResponse: HTTPURLResponse) -> Bool {
		guard self.url == otherResponse.url,
			  self.statusCode == otherResponse.statusCode,
			  self.allStringHTTPHeaders() == otherResponse.allStringHTTPHeaders() else {
			return false
		}
		return true
	}
	
	/// Tests the other URLResponse to see if it can be cast to a HTTPURLResponse and then tests for equality.
	///
	/// Once this function successfully casts otherResponse to a HTTPURLResponse it calls isBasicallyEqual for 2 HTTPURLResponses.
	/// - Parameter otherResponse: The other response to test for equality.
	/// - Returns: True if both responses have the same status code, url and headers.
	func isBasicallyEqual(to otherResponse: URLResponse) -> Bool {
		guard let localHTTPResponse = otherResponse as? HTTPURLResponse else { return false }
		return self.isBasicallyEqual(to: localHTTPResponse)
	}
}
