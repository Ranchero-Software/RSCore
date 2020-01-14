//
//  MainThreadOperation.swift
//  RSCore
//
//  Created by Brent Simmons on 1/10/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

/// Code to be run by MainThreadOperationQueue.
/// When finished, it must call delegate.operationDidComplete(self).
/// If it’s canceled, it does not need to call the delegate.
/// When it’s canceled, it should do its best to stop
/// doing whatever it’s doing. However, it should not
/// leave data in an inconsistent state.
public protocol MainThreadOperation: class {

	var isCanceled: Bool { get set }
	var id: Int? { get set } // Used by MainThreadOperationQueue; meaningless to the operation. Don’t set it.

	init(delegate: MainThreadOperationDelegate)

	/// Do the thing this operation does.
	func run()
}
