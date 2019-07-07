//
//  BatchUpdates.swift
//  DataModel
//
//  Created by Brent Simmons on 9/12/16.
//  Copyright © 2016 Ranchero Software, LLC. All rights reserved.
//

import Foundation

// Main thread only.

public typealias BatchUpdateBlock = () -> Void

public extension Notification.Name {
	static let BatchUpdateDidPerform = Notification.Name(rawValue: "BatchUpdateDidPerform")
}

public final class BatchUpdate {
	
	public static let shared = BatchUpdate()
	
	private var count = 0
	
	public var isPerforming: Bool {
		precondition(Thread.isMainThread)
		return count > 0
	}
	
	public func perform(_ batchUpdateBlock: BatchUpdateBlock) {
		precondition(Thread.isMainThread)
		incrementCount()
		batchUpdateBlock()
		decrementCount()
	}
	
	public func start() {
		precondition(Thread.isMainThread)
		incrementCount()
	}
	
	public func end() {
		precondition(Thread.isMainThread)
		decrementCount()
	}	
}

private extension BatchUpdate {
	
	func incrementCount() {
		count = count + 1
	}
	
	func decrementCount() {
		count = count - 1
		if count < 1 {
			assert(count > -1, "Expected batch updates count to be 0 or greater.")
			count = 0
			postBatchUpdateDidPerform()
		}
	}
	
	func postBatchUpdateDidPerform() {
		if !Thread.isMainThread {
			DispatchQueue.main.sync {
				NotificationCenter.default.post(name: .BatchUpdateDidPerform, object: nil, userInfo: nil)
			}
		} else {
			NotificationCenter.default.post(name: .BatchUpdateDidPerform, object: nil, userInfo: nil)
		}
	}
	
}
