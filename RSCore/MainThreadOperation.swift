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

	// These three properties are set by MainThreadOperationQueue. Don’t set them.
	var isCanceled: Bool { get set } // Check this at appropriate times in case the operation has been canceled.
	var id: Int? { get set }
	var operationDelegate: MainThreadOperationDelegate? { get set } // Make this weak.

	/// Name may be useful for debugging. Unused otherwise.
	var name: String? { get set }

	typealias MainThreadOperationCompletionBlock = (MainThreadOperation) -> Void

	/// Called when the operation completes. The completionBlock is called
	/// even if the operation was canceled. The completionBlock
	/// takes the operation as parameter, so you can inspect it as needed.
	///
	/// Implementations of MainThreadOperation are *not* responsible
	/// for calling the completionBlock — MainThreadOperationQueue
	/// handles that.
	///
	/// The completionBlock is always called on the main thread.
	/// The queue will clear the completionBlock after calling it.
	var completionBlock: MainThreadOperationCompletionBlock? { get set }

	/// Do the thing this operation does.
	///
	/// This code runs on the main thread. If you want to run
	/// code off of the main thread, you can use the standard mechanisms:
	/// a DispatchQueue, most likely.
	///
	/// When this is called, you don’t need to check isCanceled:
	/// it’s guaranteed to not be canceled. However, if you run code
	/// in another thread, you should check isCanceled in that code.
	func run()
}

// More notes:
//
// If an operation wants to cancel itself, it can.
// It needs to have a reference to its MainThreadOperationQueue,
// and then it should call queue.cancelOperation(self).

