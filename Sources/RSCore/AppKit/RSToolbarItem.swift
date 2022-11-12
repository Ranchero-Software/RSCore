//
//  RSToolbarItem.swift
//  RSCore
//
//  Created by Brent Simmons on 10/16/16.
//  Copyright © 2016 Ranchero Software, LLC. All rights reserved.
//
#if os(macOS)
import AppKit

public class RSToolbarItem: NSToolbarItem {

	override public func validate() {

		let control = self.view as? NSControl

		guard let action = self.action ?? control?.action,
			  let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? else {

			isEnabled = false
			return
		}

		let validateResult: Bool
		// Prefer `NSUserInterfaceValidations` protocol over calling `validateToolbarItem`.
		switch validator {
		case let validator as NSUserInterfaceValidations:
			validateResult = validator.validateUserInterfaceItem(self)
		default:
			validateResult = validator.validateToolbarItem(self)
		}
		isEnabled = validateResult
		control?.isEnabled = validateResult
	}
}
#endif
