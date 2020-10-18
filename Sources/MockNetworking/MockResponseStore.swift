//
//  File.swift
//  
//
//  Created by Colin Wheeler on 10/18/20.
//

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
