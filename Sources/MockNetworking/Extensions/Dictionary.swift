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
	
	func getStringHeaders(from genericHeaders: [AnyHashable:Any]) -> [String:String] {
		guard let convertedHeaders = genericHeaders as? [String:String] else { return [:] }
		return convertedHeaders
	}
}
