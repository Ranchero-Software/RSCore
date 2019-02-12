//
//  String+RSCore.swift
//  RSCore
//
//  Created by Brent Simmons on 11/26/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public extension String {

	func htmlByAddingLink(_ link: String, className: String? = nil) -> String {
		if let className = className {
			return "<a class=\"\(className)\" href=\"\(link)\">\(self)</a>"
		}
		return "<a href=\"\(link)\">\(self)</a>"
	}

	func htmlBySurroundingWithTag(_ tag: String) -> String {
		return "<\(tag)>\(self)</\(tag)>"
	}

	static func htmlWithLink(_ link: String) -> String {
		return link.htmlByAddingLink(link)
	}
}
