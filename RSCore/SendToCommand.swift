//
//  SendToCommand.swift
//  RSCore
//
//  Created by Brent Simmons on 1/8/18.
//  Copyright © 2018 Ranchero Software. All rights reserved.
//

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

// Unlike UndoableCommand commands, you instantiate one of each of these and reuse them.
// See NetNewsWire.

public protocol SendToCommand {

	var title: String { get }
	var image: RSImage? { get }

	func canSendObject(_ object: Any?, selectedText: String?) -> Bool
	func sendObject(_ object: Any?, selectedText: String?)
}

