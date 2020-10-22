//
//  File.swift
//  
//
//  Created by Colin Wheeler on 10/21/20.
//

import Foundation

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
