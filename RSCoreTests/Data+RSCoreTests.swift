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
	var bigHTML: String!

	override func setUp() {
		let bundle = Bundle(for: type(of: self))
		let htmlFile = bundle.url(forResource: "test", withExtension: "html")!
		bigHTML = try? String(contentsOf: htmlFile)
	}

	func testIsProbablyHTML() {

		let utf8 = bigHTML.data(using: .utf8)!
		XCTAssertTrue(utf8.isProbablyHTML)

		let utf16 = bigHTML.data(using: .utf16)!
		XCTAssertTrue(utf16.isProbablyHTML)

		let utf16Little = bigHTML.data(using: .utf16LittleEndian)!
		XCTAssertTrue(utf16Little.isProbablyHTML)

		let utf16Big = bigHTML.data(using: .utf16BigEndian)!
		XCTAssertTrue(utf16Big.isProbablyHTML)

	}

	func testIsProbablyHTMLPerformance() {
		let utf8 = bigHTML.data(using: .utf8)!

		self.measure {
			for _ in 0 ..< 10000 {
				let _ = utf8.isProbablyHTML
			}
		}
	}

	func testRSIsProbablyHTMLPerformance() {
		let utf8 = NSData(data: bigHTML.data(using: .utf8)!)

		self.measure {
			for _ in 0 ..< 10000 {
				let _ = utf8.rs_dataIsProbablyHTML()
			}
		}
	}
}
