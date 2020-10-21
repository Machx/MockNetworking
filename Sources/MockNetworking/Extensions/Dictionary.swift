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

extension Dictionary where Key == AnyHashable, Value == Any {
	
	/// HTTPURLProtocol initializer accepts headers as type [String:String] but
	/// when you query for `allHeaderFields` you get back [AnyHashable:Any] this
	/// is a convenience function for converting between the 2
	
	
	/// Convenience method for converting HTTPURLResponse's allHeaderFields to [String:String]
	/// - Returns: The dictionary as [String:String] type or an empty dictionary
	func getStringHeaders() -> [String:String] {
		guard let convertedHeaders = self as? [String:String] else { return [:] }
		return convertedHeaders
	}
}
