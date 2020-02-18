//
//  RSScreen.swift
//  RSCore
//
//  Created by Maurice Parker on 4/11/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

#if os(macOS)
import AppKit

public class RSScreen {

	/// The scale factor of the main screen.
	public static var mainScreenScale: CGFloat = {
		return NSScreen.main?.backingScaleFactor ?? CGFloat(integerLiteral: 1)
	}()
	
}

#endif

#if os(iOS)
import UIKit

public class RSScreen {

	/// The scale factor of the main screen.
	public static var mainScreenScale: CGFloat = {
		return UIScreen.main.scale
	}()
	
}

#endif
