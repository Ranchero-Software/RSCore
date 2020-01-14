//
//  MainThreadOperationQueue.swift
//  RSCore
//
//  Created by Brent Simmons on 1/10/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public protocol MainThreadOperationDelegate: class {
	func operationDidComplete(_ operation: MainThreadOperation)
}

/// Manage a queue of RSOperation tasks.
/// Runs them one at a time; runs them on the main thread.
/// Any operation can use DispatchQueue or whatever to run code off of the main thread.
/// An operation calls back to the queue when it’s completed or canceled.
/// Use this only on the main thread.
/// The operation can be suspended and resumed.
/// It is *not* suspended on creation.
public final class MainThreadOperationQueue {

	private var operations = [Int: MainThreadOperation]()
	private var pendingOperationIDs = [Int]()
	private var currentOperationID: Int?
	private var incrementingID = 0
	private var isSuspended = false
	private let dependencies = MainThreadOperationDependencies()

	public init() {
		// Silence compiler complaint about init not being public.
	}

	deinit {
		cancelAllOperations()
	}

	/// Add an operation to the queue.
	public func addOperation(_ operation: MainThreadOperation) {
		precondition(Thread.isMainThread)
		operation.operationDelegate = self
		let operationID = ensureOperationID(operation)
		operations[operationID] = operation

		assert(!pendingOperationIDs.contains(operationID))
		if !pendingOperationIDs.contains(operationID) {
			pendingOperationIDs.append(operationID)
		}

		runNextOperationIfNeeded()
	}

	/// Add multiple operations to the queue.
	/// This has the same effect as calling addOperation one-by-one.
	public func addOperations(_ operations: [MainThreadOperation]) {
		for operation in operations {
			addOperation(operation)
		}
	}

	/// Add a dependency. Do this *before* calling addOperation, since addOperation might run the operation right away.
	public func make(_ childOperation: MainThreadOperation, dependOn parentOperation: MainThreadOperation) {
		precondition(Thread.isMainThread)
		let childOperationID = ensureOperationID(childOperation)
		let parentOperationID = ensureOperationID(parentOperation)
		dependencies.make(childOperationID, dependOn: parentOperationID)
	}

	/// Cancel all the current and pending operations.
	public func cancelAllOperations() {
		precondition(Thread.isMainThread)
		var operationIDsToCancel = pendingOperationIDs
		if let currentOperationID = currentOperationID {
			operationIDsToCancel.append(currentOperationID)
		}
		cancel(operationIDsToCancel)
	}

	/// Cancel some operations. If any of them have dependent operations,
	/// those operations will be canceled also.
	public func cancelOperations(_ operations: [MainThreadOperation]) {
		precondition(Thread.isMainThread)
		let operationIDsToCancel = operations.map{ ensureOperationID($0) }
		cancel(operationIDsToCancel)
		runNextOperationIfNeeded()
	}

	/// Stop running operations until resume() is called.
	/// The current operation, if there is one, will run to completion —
	/// it will not be canceled.
	public func suspend() {
		precondition(Thread.isMainThread)
		isSuspended = true
	}

	/// Resume running operations.
	public func resume() {
		precondition(Thread.isMainThread)
		isSuspended = false
		runNextOperationIfNeeded()
	}
}

extension MainThreadOperationQueue: MainThreadOperationDelegate {

	public func operationDidComplete(_ operation: MainThreadOperation) {
		operationDidFinish(operation)
	}
}

private extension MainThreadOperationQueue {

	func operationDidFinish(_ operation: MainThreadOperation) {
		guard let operationID = operation.id else {
			assertionFailure("Expected operation.id, got nil")
			return
		}
		if let currentOperationID = currentOperationID, currentOperationID == operationID {
			self.currentOperationID = nil
		}

		if !operation.isCanceled {
			dependencies.operationIDDidComplete(operationID)
		}
		removeFromStorage(operation)
		operation.operationDelegate = nil
		runNextOperationIfNeeded()
	}

	func runNextOperationIfNeeded() {
		DispatchQueue.main.async {
			guard !self.isSuspended && !self.isRunningAnOperation() else {
				return
			}
			guard let operation = self.nextAvailableOperation() else {
				return
			}
			self.currentOperationID = operation.id!
			operation.run()
		}
	}

	func isRunningAnOperation() -> Bool {
		return currentOperationID != nil
	}

	func nextAvailableOperation() -> MainThreadOperation? {
		for operationID in pendingOperationIDs {
			guard let operation = operations[operationID] else {
				assertionFailure("Expected pending operation to be found in operations dictionary.")
				continue
			}
			if operationIsAvailable(operation) {
				return operation
			}
		}
		return nil
	}

	func operationIsAvailable(_ operation: MainThreadOperation) -> Bool {
		return !operation.isCanceled && !dependencies.operationIDIsBlockedByDependency(operation.id!)
	}

	func createOperationID() -> Int {
		incrementingID += 1
		return incrementingID
	}

	func ensureOperationID(_ operation: MainThreadOperation) -> Int {
		if let operationID = operation.id {
			return operationID
		}

		let operationID = createOperationID()
		operation.id = operationID
		return operationID
	}

	func cancel(_ operationIDs: [Int]) {
		let operationIDsToCancel = operationIDsByAddingChildOperationIDs(operationIDs)
		setCanceledAndRemoveDelegate(for: operationIDsToCancel)
		clearCurrentOperationIDIfContained(by: operationIDsToCancel)
		removeOperationIDsFromPendingOperationIDs(operationIDsToCancel)
		dependencies.cancel(operationIDsToCancel)
	}

	func operationIDsByAddingChildOperationIDs(_ operationIDs: [Int]) -> [Int] {
		var operationIDsToCancel = operationIDs
		for operationID in operationIDs {
			if let childOperationIDs = dependencies.childOperationIDs(for: operationID) {
				operationIDsToCancel += childOperationIDs
			}
		}
		return operationIDsToCancel
	}

	func setCanceledAndRemoveDelegate(for operationIDs: [Int]) {
		for operationID in operationIDs {
			if let operation = operations[operationID] {
				operation.isCanceled = true
				operation.operationDelegate = nil
			}
		}
	}

	func clearCurrentOperationIDIfContained(by operationIDs: [Int]) {
		if let currentOperationID = currentOperationID, operationIDs.contains(currentOperationID) {
			self.currentOperationID = nil
		}
	}

	func removeOperationIDsFromPendingOperationIDs(_ operationIDs: [Int]) {
		var updatedPendingOperationIDs = pendingOperationIDs
		for operationID in operationIDs {
			if let ix = updatedPendingOperationIDs.firstIndex(of: operationID) {
				updatedPendingOperationIDs.remove(at: ix)
			}
		}

		pendingOperationIDs = updatedPendingOperationIDs
	}

	func removeFromStorage(_ operation: MainThreadOperation) {
		DispatchQueue.main.async {
			guard let operationID = operation.id else {
				assertionFailure("Expected operation.id, got nil.")
				return
			}
			self.operations[operationID] = nil
		}
	}
}

private final class MainThreadOperationDependencies {

	private var dependencies = [Int: Dependency]() // Key is parentOperationID

	private final class Dependency {

		let operationID: Int
		var parentOperationDidComplete = false
		var isEmpty: Bool {
			return childOperationIDs.isEmpty
		}
		var childOperationIDs = [Int]()

		init(operationID: Int) {
			self.operationID = operationID
		}

		func remove(_ childOperationID: Int) {
			if let ix = childOperationIDs.firstIndex(of: childOperationID) {
				childOperationIDs.remove(at: ix)
			}
		}

		func add(_ childOperationID: Int) {
			guard !childOperationIDs.contains(childOperationID) else {
				return
			}
			childOperationIDs.append(childOperationID)
		}

		func operationIDIsBlocked(_ operationID: Int) -> Bool {
			if parentOperationDidComplete {
				return false
			}
			return childOperationIDs.contains(operationID)
		}
	}

	/// Add a dependency: make childOperationID dependent on parentOperationID.
	func make(_ childOperationID: Int, dependOn parentOperationID: Int) {
		let dependency = ensureDependency(parentOperationID)
		dependency.add(childOperationID)
	}

	/// Child operationIDs for a possible dependency.
	func childOperationIDs(for parentOperationID: Int) -> [Int]? {
		if let dependency = dependencies[parentOperationID] {
			return dependency.childOperationIDs
		}
		return nil
	}

	/// Call this, when an operation is completed, to update the dependencies.
	func operationIDDidComplete(_ operationID: Int) {
		if let dependency = dependencies[operationID] {
			dependency.parentOperationDidComplete = true
		}
		removeChildOperationID(operationID)
		removeEmptyDependencies()
	}

	/// Call this, when canceling, to update the dependenceis.
	func cancel(_ operationIDs: [Int]) {
		removeAllReferencesToOperationIDs(operationIDs)
	}

	/// Find out if an operationID is blocked by a dependency.
	func operationIDIsBlockedByDependency(_ operationID: Int) -> Bool {
		for dependency in dependencies.values {
			if dependency.operationIDIsBlocked(operationID) {
				return true
			}
		}
		return false
	}

	private func ensureDependency(_ parentOperationID: Int) -> Dependency {
		if let dependency = dependencies[parentOperationID] {
			return dependency
		}
		let dependency = Dependency(operationID: parentOperationID)
		dependencies[parentOperationID] = dependency
		return dependency
	}
}

private extension MainThreadOperationDependencies {

	func removeAllReferencesToOperationIDs(_ operationIDs: [Int]) {
		removeDependencies(operationIDs)
		removeChildOperationIDs(operationIDs)
	}

	func removeDependencies(_ parentOperationIDs: [Int]) {
		parentOperationIDs.forEach { dependencies[$0] = nil }
	}

	func removeChildOperationIDs(_ operationIDs: [Int]) {
		operationIDs.forEach{ removeChildOperationID($0) }
		removeEmptyDependencies()
	}

	func removeChildOperationID(_ operationID: Int) {
		dependencies.values.forEach{ $0.remove(operationID) }
	}

	func removeEmptyDependencies() {
		let parentOperationIDs = dependencies.keys
		for parentOperationID in parentOperationIDs {
			let dependency = dependencies[parentOperationID]!
			if dependency.isEmpty {
				dependencies[parentOperationID] = nil
			}
		}
	}
}
