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
    
    func testCancelingDisownsOperation() {
        
        final class SlowFinishingOperation: MainThreadOperation {

            // MainThreadOperation
            var isCanceled = false {
                didSet {
                    if isCanceled {
                        didCancelExpectation?.fulfill()
                    }
                }
            }
            var didCancelExpectation: XCTestExpectation?
            
            var id: Int?
            var operationDelegate: MainThreadOperationDelegate?
            var name: String?
            var completionBlock: MainThreadOperation.MainThreadOperationCompletionBlock?
            
            var didStartRunBlock: (() -> ())?

            func run() {
                guard let block = didStartRunBlock else {
                    XCTFail("Unable to test cancelation of running operation.")
                    return
                }
                block()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        XCTFail("Could not complete slow finishing operation because it seems to be prematurely disowned.")
                        return
                    }
                    self.operationDelegate?.operationDidComplete(self)
                }
            }
        }
        
        let queue = MainThreadOperationQueue()
        let completionExpectation = expectation(description: "Slow Finishing Operation Did Complete")
        
        // Using an Optional allows us to control this scope's ownership of the operation.
        var operation: SlowFinishingOperation? = {
            let operation = SlowFinishingOperation()
            operation.didCancelExpectation = expectation(description: "Did Cancel Operation")
            operation.didStartRunBlock = { [weak operation] in
                guard let operation = operation else {
                    XCTFail("Could not cancel slow finishing operation because it seems to be prematurely disowned.")
                    return
                }
                queue.cancelOperation(operation)
            }
            operation.completionBlock = { _ in
                XCTAssertTrue(Thread.isMainThread)
                completionExpectation.fulfill()
            }
            return operation
        }()
        
        // The queue should take ownership of the operation (asserted below).
        queue.addOperation(operation!)
        
        // Verify something other than this scope has ownership of the operation.
        weak var addedOperation = operation!
        operation = nil
        XCTAssertNil(operation)
        XCTAssertNotNil(addedOperation, "Perhaps the queue did not take ownership of the operation?")
        
        // Wait for the operation to start running, cancel and complete.
        waitForExpectations(timeout: 1)
        
        XCTAssertNil(addedOperation, "Perhaps the queue did not disown the operation?")
    }
}
