//
//  File.swift
//  
//
//  Created by Colin Wheeler on 10/11/20.
//

import Foundation

public extension URLSession {
	class func sessionWith(_ configuration: URLSessionConfiguration, delegate: URLSessionDownloadDelegate? = nil) {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: configuration,
								 delegate: delegate,
								 delegateQueue: nil)
		return session
	}
}
