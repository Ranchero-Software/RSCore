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

	lazy var bundle = Bundle(for: type(of: self))

	override func setUp() {
		let htmlFile = bundle.url(forResource: "test", withExtension: "html")!
		bigHTML = try? String(contentsOf: htmlFile)
	}

	func testIsProbablyHTMLEncodings() {

		let utf8 = bigHTML.data(using: .utf8)!
		XCTAssertTrue(utf8.isProbablyHTML)

		let utf16 = bigHTML.data(using: .utf16)!
		XCTAssertTrue(utf16.isProbablyHTML)

		let utf16Little = bigHTML.data(using: .utf16LittleEndian)!
		XCTAssertTrue(utf16Little.isProbablyHTML)

		let utf16Big = bigHTML.data(using: .utf16BigEndian)!
		XCTAssertTrue(utf16Big.isProbablyHTML)

		let shiftJIS = bigHTML.data(using: .shiftJIS)!
		XCTAssertTrue(shiftJIS.isProbablyHTML)

		let japaneseEUC = bigHTML.data(using: .japaneseEUC)!
		XCTAssertTrue(japaneseEUC.isProbablyHTML)

	}

	func testIsProbablyHTMLTags() {

		let noLT = "html body".data(using: .utf8)!
		XCTAssertFalse(noLT.isProbablyHTML)

		let noBody = "<html><head></head></html>".data(using: .utf8)!
		XCTAssertFalse(noBody.isProbablyHTML)

		let noHead = "<body>foo</body>".data(using: .utf8)!
		XCTAssertFalse(noHead.isProbablyHTML)

		let lowerHTMLLowerBODY = "<html><body></body></html>".data(using: .utf8)!
		XCTAssertTrue(lowerHTMLLowerBODY.isProbablyHTML)

		let upperHTMLUpperBODY = "<HTML><BODY></BODY></HTML>".data(using: .utf8)!
		XCTAssertTrue(upperHTMLUpperBODY.isProbablyHTML)

		let lowerHTMLUpperBODY = "<html><BODY></BODY></html>".data(using: .utf8)!
		XCTAssertTrue(lowerHTMLUpperBODY.isProbablyHTML)

		let upperHTMLLowerBODY = "<HTML><body></body></HTML>".data(using: .utf8)!
		XCTAssertTrue(upperHTMLLowerBODY.isProbablyHTML)

	}

	func testIsProbablyHTMLPerformance() {
		let utf8 = bigHTML.data(using: .utf8)!

		self.measure {
			for _ in 0 ..< 10000 {
				let _ = utf8.isProbablyHTML
			}
		}
	}

	func testIsImage() {
		let pngURL = bundle.url(forResource: "icon", withExtension: "png")!
		let pngData = try! Data(contentsOf: pngURL)

		let jpegURL = bundle.url(forResource: "icon", withExtension: "jpg")!
		let jpegData = try! Data(contentsOf: jpegURL)

		let gifURL = bundle.url(forResource: "icon", withExtension: "gif")!
		let gifData = try! Data(contentsOf: gifURL)

		XCTAssertTrue(pngData.isPNG)
		XCTAssertTrue(jpegData.isJPEG)
		XCTAssertTrue(gifData.isGIF)

		XCTAssertTrue(pngData.isImage)
		XCTAssertTrue(jpegData.isImage)
		XCTAssertTrue(gifData.isImage)
	}

	func testMD5() {
		XCTAssertEqual("foobar".md5String, "3858f62230ac3c915f300c664312c63f")
		XCTAssertEqual("".md5String, "d41d8cd98f00b204e9800998ecf8427e")
	}

}
