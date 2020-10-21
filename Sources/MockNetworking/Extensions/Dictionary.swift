//
//  File.swift
//  
//
//  Created by Colin Wheeler on 10/20/20.
//

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
