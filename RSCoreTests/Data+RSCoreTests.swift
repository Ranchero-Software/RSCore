//
//  Data+RSCoreTests.swift
//  RSCoreTests
//
//  Created by Nate Weaver on 2020-01-12.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import XCTest
@testable import RSCore

class Data_RSCoreTests: XCTestCase {

	let htmlTest = "<html><head><title>Sample HTML</title></head><body>Some body text</body></html>"

	func testIsProbablyHTML() {

		let utf8 = htmlTest.data(using: .utf8)!
		XCTAssertTrue(utf8.isProbablyHTML)

		let utf16 = htmlTest.data(using: .utf16)!
		XCTAssertTrue(utf16.isProbablyHTML)

		let utf16Little = htmlTest.data(using: .utf16LittleEndian)!
		XCTAssertTrue(utf16Little.isProbablyHTML)

		let utf16Big = htmlTest.data(using: .utf16BigEndian)!
		XCTAssertTrue(utf16Big.isProbablyHTML)

	}

	func testIsProbablyHTMLPerformance() {
		let utf8 = htmlTest.data(using: .utf8)!

		self.measure {
			for _ in 0 ..< 10000 {
				let _ = utf8.isProbablyHTML
			}
		}
	}

	func testRSIsProbablyHTMLPerformance() {
		let utf8 = NSData(data: htmlTest.data(using: .utf8)!)

		self.measure {
			for _ in 0 ..< 10000 {
				let _ = utf8.rs_dataIsProbablyHTML()
			}
		}
	}
}
