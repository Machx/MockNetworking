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

public extension URLSession {
	
	/// Convenience function for easy URLSession setup
	/// - Parameters:
	///   - configuration: The URLSession configuration to use
	///   - delegate: The URLSession delegate to assign
	/// - Returns: A URLSession configured with the given parameters.
	class func sessionWith(_ configuration: URLSessionConfiguration?, delegate: URLSessionDownloadDelegate? = nil) -> URLSession {
		let configuration = configuration ?? URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		let session = URLSession(configuration: configuration,
								 delegate: delegate,
								 delegateQueue: nil)
		return session
	}
}
