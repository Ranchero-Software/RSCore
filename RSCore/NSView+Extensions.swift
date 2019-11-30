//
//  NSView+Extensions.swift
//  RSCore
//
//  Created by Maurice Parker on 11/12/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation

extension NSView {
	
    public func asImage() -> NSImage {
		let rep = bitmapImageRepForCachingDisplay(in: bounds)!
		cacheDisplay(in: bounds, to: rep)
		
		let img = NSImage(size: bounds.size)
		img.addRepresentation(rep)
		return img
    }
	
}
