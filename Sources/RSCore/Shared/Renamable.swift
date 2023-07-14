//
//  Renamable.swift
//  RSCore
//
//  Created by Brent Simmons on 11/22/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import Foundation

/// For anything that can be renamed by the user.
public protocol Renamable {

	/// Renames an object.
	/// - Parameters:
	///   - to: The new name for the object.
	func rename(to: String) async throws
}
