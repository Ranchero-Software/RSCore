//
//  Blocks.swift
//  RSCore
//
//  Created by Brent Simmons on 11/29/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public typealias VoidCompletionBlock = () -> ()

/// Call a VoidCompletionBlock on the main thread.
public func callVoidCompletionBlock(_ block: @escaping VoidCompletionBlock) {
	DispatchQueue.main.async(execute: block)
}
