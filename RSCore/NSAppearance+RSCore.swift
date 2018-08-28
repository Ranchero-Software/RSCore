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

		// Until we are building against the 10.14 SDK, we have to dynamically lookup and message NSAppearance.bestMatch,
		// and also define .darkAqua literally since it's not present in the 10.13 SDK.
		#if swift(>=4.2)
			if #available(macOS 10.14, *) {
				if self.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
					isDarkMode = true
				}
				else {
					isDarkMode = false
				}
			}
			else {
				isDarkMode = false
			}
		#else
			if #available(macOS 10.14, *) {
				let darkAquaAppearanceName = NSAppearance.Name(rawValue: "NSAppearanceNameDarkAqua") // .darkAqua
				let appearances = [darkAquaAppearanceName, .aqua]
				let bestMatchSelector = NSSelectorFromString("bestMatchFromAppearancesWithNames:")
				let currentMode: NSAppearance.Name? = self.perform(bestMatchSelector, with: appearances)?.takeUnretainedValue() as? NSAppearance.Name
				if currentMode == darkAquaAppearanceName {
					isDarkMode = true
				}
				else {
					isDarkMode = false
				}
			}
			else {
				isDarkMode = false
			}
		#endif
		return isDarkMode
	}
}
