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
import Konkyo

/// Central location for storing the responses for given URL's.
///
/// This class is thread safe and will atomically read & update values.
final class MockResponseStore {
	static let shared = MockResponseStore()
	
	private var _storedResponses = [URL: MockPropertyResponse]()
	private var _load_mutex = Mutex()
	
	init() {}
	
	subscript(url: URL) -> MockPropertyResponse? {
		get {
			_load_mutex.lock()
			defer { _load_mutex.unlock() }
			return _storedResponses[url]
		}
		set {
			_load_mutex.lock()
			defer { _load_mutex.unlock() }
			_storedResponses[url] = newValue
		}
	}
	
	func contains(url: URL) -> Bool {
		_load_mutex.lock()
		defer { _load_mutex.unlock() }
		return _storedResponses.keys.contains(url)
	}
	
	func removeResponse(for url: URL) -> Bool {
		_load_mutex.lock()
		defer { _load_mutex.unlock() }
		return _storedResponses.removeValue(forKey: url) != nil
	}
	
	func removeAllReponses() {
		_load_mutex.lock()
		defer { _load_mutex.unlock() }
		_storedResponses.removeAll()
	}
}
