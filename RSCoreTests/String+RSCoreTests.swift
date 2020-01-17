//
//  String+RSCore.swift
//  RSCoreTests
//
//  Created by Nate Weaver on 2020-01-14.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import XCTest

class String_RSCore: XCTestCase {

	func testCollapsingWhitespace() {

		let str = "   lots\t\tof   random\n\nwhitespace\r\n"
		let expected = "lots of random whitespace"
		XCTAssertEqual(str.collapsingWhitespace, expected)

	}

	func testTrimmingWhitespace() {

		let str = "   lots\t\tof   random\n\nwhitespace\r\n"
		let expected = "lots\t\tof   random\n\nwhitespace"
		XCTAssertEqual(str.trimmingWhitespace, expected)

		// Ported old tests
		var s = "\tfoo\n\n\t\r\t"
		var result = s.trimmingWhitespace
		XCTAssertEqual(result, "foo")

		s = "\t\n\n\t\r\t"
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "")

		s = "\t"
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "")

		s = ""
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "")

		s = "\nfoo\n"
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "foo")

		s = "\nfoo"
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "foo")

		s = "foo\n"
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "foo")

		s = "fo\n\n\n\n\n\no\n"
		result = s.trimmingWhitespace
		XCTAssertEqual(result, "fo\n\n\n\n\n\no")


	}

	func testStrippingpPrefix() {

		let str = "foobar"
		let expected = "bar"
		XCTAssertEqual(str.stripping(prefix: "foo", caseSensitive: true), expected)

		XCTAssertEqual(str.stripping(prefix: "FOO"), expected)

		XCTAssertEqual(str.stripping(prefix: "FOO", caseSensitive: true), str)

	}

	func testEscapingSpecialXMLCharacters() {

		let str = #"<foo attr="value">bar&baz</foo>"#
		let expected = "&lt;foo attr=&quot;value&quot;&gt;bar&amp;baz&lt;/foo&gt;"
		XCTAssertEqual(str.escapingSpecialXMLCharacters, expected)

	}

	func testStrippingHTTPOrHTTPSScheme() {

		let http = "http://ranchero.com/"
		let expected = "ranchero.com/"
		XCTAssertEqual(http.strippingHTTPOrHTTPSScheme, expected)

		let https = "https://ranchero.com/"
		XCTAssertEqual(https.strippingHTTPOrHTTPSScheme, expected)

		let noreplacement = "example://ranchero.com/"
		XCTAssertEqual(noreplacement.strippingHTTPOrHTTPSScheme, noreplacement)

	}

	func testMD5HashStringPerformance() {

		let s1 = "These are the times that try men’s souls."
		let s2 = "These are the times that men’s souls."
		let s3 = "These ar th time that try men’s souls."
		let s4 = "These are the times that try men’s."
		let s5 = "These are the that try men’s souls."
		let s6 = "These are times that try men’s souls."
		let s7 = "are the times that try men’s souls."
		let s8 = "These the times that try men’s souls."
		let s9 = "These are the times tht try men’s souls."
		let s10 = "These are the times that try men's souls."

		self.measure {
			for _ in 0..<1000 {
				let _ = s1.md5HashString
				let _ = s2.md5HashString
				let _ = s3.md5HashString
				let _ = s4.md5HashString
				let _ = s5.md5HashString
				let _ = s6.md5HashString
				let _ = s7.md5HashString
				let _ = s8.md5HashString
				let _ = s9.md5HashString
				let _ = s10.md5HashString
			}
		}
	}

}
