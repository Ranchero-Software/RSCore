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

	}

	func testStrippingpPrefix() {

		let str = "foobar"
		let expected = "bar"
		XCTAssertEqual(str.strippingPrefix("foo", caseSensitive: true), expected)

		XCTAssertEqual(str.strippingPrefix("FOO"), expected)

		XCTAssertEqual(str.strippingPrefix("FOO", caseSensitive: true), str)

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
}
