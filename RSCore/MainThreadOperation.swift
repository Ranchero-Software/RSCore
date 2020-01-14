//
//  MainThreadOperation.swift
//  RSCore
//
//  Created by Brent Simmons on 1/10/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

/// Code to be run by MainThreadOperationQueue.
/// When finished, it must call operationDelegate.operationDidComplete(self).
/// If it’s canceled, it should not call the delegate.
/// When it’s canceled, it should do its best to stop
/// doing whatever it’s doing. However, it should not
/// leave data in an inconsistent state.
public protocol MainThreadOperation: class {

	// These properties are set by MainThreadOperationQueue. Don’t set them.
	var isCanceled: Bool { get set } // Check this at appropriate times in case the operation has been canceled.
	var id: Int? { get set }
	var operationDelegate: MainThreadOperationDelegate? { get set } // Make this weak.

	/// Do the thing this operation does.
	func run()
}
