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
//		defer {
//			MockURLProtocol.unregister()
//		}
		
		//
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
