//
//  MainThreadOperationTests.swift
//  RSCoreTests
//
//  Created by Brent Simmons on 1/17/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import XCTest
@testable import RSCore

class MainThreadOperationTests: XCTestCase {

	func testSingleOperation() {
		let queue = MainThreadOperationQueue()
		var operationDidRun = false
		let singleOperationDidRunExpectation = expectation(description: "singleOperationDidRun")
		let operation = MainThreadBlockOperation {
			operationDidRun = true
			XCTAssertTrue(operationDidRun)
			singleOperationDidRunExpectation.fulfill()
		}
		queue.addOperation(operation)

		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testOperationAndDependency() {
		let queue = MainThreadOperationQueue()
		var operationIndex = 0

		let parentOperationExpectation = expectation(description: "parentOperation")
		let parentOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 0)
			operationIndex += 1
			parentOperationExpectation.fulfill()
		}

		let childOperationExpectation = expectation(description: "childOperation")
		let childOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 1)
			operationIndex += 1
			childOperationExpectation.fulfill()
		}

		queue.make(childOperation, dependOn: parentOperation)
		queue.addOperation(parentOperation)
		queue.addOperation(childOperation)

		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testOperationAndDependencyAddedOutOfOrder() {
		let queue = MainThreadOperationQueue()
		var operationIndex = 0

		let parentOperationExpectation = expectation(description: "parentOperation")
		let parentOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 0)
			operationIndex += 1
			parentOperationExpectation.fulfill()
		}

		let childOperationExpectation = expectation(description: "childOperation")
		let childOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 1)
			operationIndex += 1
			childOperationExpectation.fulfill()
		}

		queue.make(childOperation, dependOn: parentOperation)
		queue.addOperation(childOperation)
		queue.addOperation(parentOperation)

		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testOperationAndTwoDependenciesAddedOutOfOrder() {
		let queue = MainThreadOperationQueue()
		var operationIndex = 0

		let parentOperationExpectation = expectation(description: "parentOperation")
		let parentOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 0)
			operationIndex += 1
			parentOperationExpectation.fulfill()
		}

		let childOperationExpectation = expectation(description: "childOperation")
		let childOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 1)
			operationIndex += 1
			childOperationExpectation.fulfill()
		}

		let childOperationExpectation2 = expectation(description: "childOperation2")
		let childOperation2 = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 2)
			operationIndex += 1
			childOperationExpectation2.fulfill()
		}

		queue.make(childOperation, dependOn: parentOperation)
		queue.make(childOperation2, dependOn: parentOperation)
		queue.addOperation(childOperation)
		queue.addOperation(childOperation2)
		queue.addOperation(parentOperation)

		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testChildOperationWithTwoDependencies() {
		let queue = MainThreadOperationQueue()
		var operationIndex = 0

		let parentOperationExpectation = expectation(description: "parentOperation")
		let parentOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 0)
			operationIndex += 1
			parentOperationExpectation.fulfill()
		}

		let parentOperationExpectation2 = expectation(description: "parentOperation2")
		let parentOperation2 = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 1)
			operationIndex += 1
			parentOperationExpectation2.fulfill()
		}

		let childOperationExpectation = expectation(description: "childOperation")
		let childOperation = MainThreadBlockOperation {
			XCTAssertTrue(operationIndex == 2)
			operationIndex += 1
			childOperationExpectation.fulfill()
		}

		queue.make(childOperation, dependOn: parentOperation)
		queue.make(childOperation, dependOn: parentOperation2)
		queue.addOperation(childOperation)
		queue.addOperation(parentOperation)
		queue.addOperation(parentOperation2)

		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testAddingManyOperations() {
		let queue = MainThreadOperationQueue()
		let operationsCount = 1000
		var operationIndex = 0
		var operations = [MainThreadBlockOperation]()

		for i in 0..<operationsCount {
			let operationExpectation = expectation(description: "Operation \(i)")
			let operation = MainThreadBlockOperation {
				XCTAssertTrue(operationIndex == i)
				operationIndex += 1
				operationExpectation.fulfill()
			}
			operations.append(operation)
		}

		queue.addOperations(operations)
		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testAddingManyOperationsAndCancelingManyOperations() {
		let queue = MainThreadOperationQueue()
		let operationsCount = 1000
		var operations = [MainThreadBlockOperation]()

		for _ in 0..<operationsCount {
			let operation = MainThreadBlockOperation {
				XCTAssertTrue(false)
			}
			operations.append(operation)
		}

		queue.addOperations(operations)
		queue.cancelOperations(operations)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}

	func testAddingManyOperationsWithCompletionBlocks() {
		let queue = MainThreadOperationQueue()
		let operationsCount = 100
		var operationIndex = 0
		var operations = [MainThreadBlockOperation]()

		for i in 0..<operationsCount {
			let operationExpectation = expectation(description: "Operation \(i)")
			let operationCompletionBlockExpectation = expectation(description: "Operation Completion \(i)")
			let operation = MainThreadBlockOperation {
				XCTAssertTrue(operationIndex == i)
				operationExpectation.fulfill()
			}
			operation.completionBlock = { completedOperation in
				XCTAssert(operation === completedOperation)
				XCTAssertTrue(operationIndex == i)
				operationIndex += 1
				operationCompletionBlockExpectation.fulfill()
			}
			operations.append(operation)
		}

		queue.addOperations(operations)
		waitForExpectations(timeout: 1.0, handler: nil)
		XCTAssertTrue(queue.pendingOperationsCount == 0)
	}
}
