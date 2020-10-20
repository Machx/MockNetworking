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

final class MockResponseStore {
	static let shared = MockResponseStore()
	
	private var _storedResponses = [URL: MockPropertyResponse]()
	
	init() {}
	
	subscript(url: URL) -> MockPropertyResponse? {
		get {
			return _storedResponses[url]
		}
		
		set {
			_storedResponses[url] = newValue
		}
	}
	
	func contains(url: URL) -> Bool {
		return _storedResponses.keys.contains(url)
	}
	
	func removeAllReponses() {
		_storedResponses.removeAll()
	}
	
	func removeResponse(for url: URL) -> Bool {
		return _storedResponses.removeValue(forKey: url) != nil
	}
}
