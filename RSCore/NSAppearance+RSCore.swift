//
//  NSAppearance+RSCore.swift
//  RSCore
//
//  Created by Daniel Jalkut on 8/28/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import AppKit

extension NSAppearance {
	@objc(rsIsDarkMode)
	public var isDarkMode: Bool {
		let isDarkMode: Bool

		if #available(macOS 10.14, *) {
			if self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
				isDarkMode = true
			}
			else {
				isDarkMode = false
			}
		}
		else {
			isDarkMode = false
		}
		return isDarkMode
	}
}
