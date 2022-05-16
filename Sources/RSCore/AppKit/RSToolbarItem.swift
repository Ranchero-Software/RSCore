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

		guard let control = self.view as? NSControl, let action = self.action,
			  let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? else {

			isEnabled = false
			return
		}

		// Prefer `NSUserInterfaceValidations` protocol over calling `validateToolbarItem`.
		switch validator {
		case let validator as NSUserInterfaceValidations:
			control.isEnabled = validator.validateUserInterfaceItem(self)
		default:
			control.isEnabled = validator.validateToolbarItem(self)
		}
	}
}
#endif
