//
//  String+RSCore.swift
//  RSCore
//
//  Created by Brent Simmons on 11/26/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public extension String {

	public func htmlByAddingLink(_ link: String, className: String? = nil) -> String {
		if let className = className {
			return "<a class=\"\(className)\" href=\"\(link)\">\(self)</a>"
		}
		return "<a href=\"\(link)\">\(self)</a>"
	}

	public func htmlBySurroundingWithTag(_ tag: String) -> String {
		return "<\(tag)>\(self)</\(tag)>"
	}

	static public func htmlWithLink(_ link: String) -> String {
		return link.htmlByAddingLink(link)
	}
}
