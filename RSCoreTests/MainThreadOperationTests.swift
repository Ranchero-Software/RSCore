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
	}

}
