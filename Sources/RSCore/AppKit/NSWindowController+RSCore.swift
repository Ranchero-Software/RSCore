//
//  NSWindowController+RSCore.swift
//  RSCore
//
//  Created by Brent Simmons on 2/17/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

#if os(macOS)
import AppKit

@MainActor public extension NSWindowController {

	var isDisplayingSheet: Bool {
        window?.isDisplayingSheet ?? false
	}

	var isOpen: Bool {
        isWindowLoaded && window!.isVisible
	}
}
#endif
