//
//  String+RSCore.swift
//  RSCore
//
//  Created by Brent Simmons on 11/26/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import CommonCrypto

public extension String {

	func htmlByAddingLink(_ link: String, className: String? = nil) -> String {
		if let className = className {
			return "<a class=\"\(className)\" href=\"\(link)\">\(self)</a>"
		}
		return "<a href=\"\(link)\">\(self)</a>"
	}

	func htmlBySurroundingWithTag(_ tag: String) -> String {
		return "<\(tag)>\(self)</\(tag)>"
	}

	static func htmlWithLink(_ link: String) -> String {
		return link.htmlByAddingLink(link)
	}
	
    func hmacUsingSHA1(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key, key.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
	
}

public extension String {

	var md5HashData: Data {
		NSData(data: self.data(using: .utf8)!).rs_md5Hash()
	}

	var md5HashString: String {
		NSData(data: self.md5HashData).rs_hexadecimalString()
	}

	/// Trims leading and trailing whitespace, and collapses other whitespace into a single space.
	var collapsingWhitespace: String {
		var dest = self
		dest = dest.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		return dest.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
	}

	/// Trims whitespace from the beginning and end of the string.
	var trimmingWhitespace: String {
		self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}

	/// Returns `true` if the string contains any character from a set.
	private func containsAnyCharacter(from charset: CharacterSet) -> Bool {
		return self.rangeOfCharacter(from: charset) != nil
	}

	/// Returns `true` if a string may be an IPv6 URL.
	private var mayBeIPv6URL: Bool {
		self.range(of: "\\[[0-9a-fA-F:]+\\]", options: .regularExpression) != nil
	}

	/// Returns `true` if the string may be a URL.
	var mayBeURL: Bool {

		let s = self.trimmingWhitespace

		if s.isEmpty || (!s.contains(".") && !s.mayBeIPv6URL) {
			return false
		}

		let banned = CharacterSet.whitespacesAndNewlines.union(.controlCharacters).union(.illegalCharacters)

		if s.containsAnyCharacter(from: banned) {
			return false
		}

		return true

	}


	/// Removes a prefix from the beginning of a string.
	/// - Parameters:
	///   - prefix: The prefix to remove
	///   - caseSensitive: `true` if the prefix should be matched case-sensitively.
	/// - Returns: A new string with the prefix removed.
	func strippingPrefix(_ prefix: String, caseSensitive: Bool = false) -> String {
		let options: String.CompareOptions = caseSensitive ? .anchored : [.anchored, .caseInsensitive]
		return self.replacingOccurrences(of: prefix, with: "", options: options)
	}

	/// A copy of an HTML string converted to plain text.
	///
	/// Replaces `p`, `blockquote`, `div`, `br`, and `li` tags with varying quantities
	/// of newlines, and guarantees no more than two consecutive newlines.
	var convertedToPlainText: String {
		if !self.contains("<") {
			return self
		}

		var preflight = self

		let options: String.CompareOptions = [.regularExpression, .caseInsensitive]
		preflight = preflight.replacingOccurrences(of: "</?blockquote>|</p>", with: "\n\n", options: options)
		preflight = preflight.replacingOccurrences(of: "<p>|</?div>|<br(?: ?/)?>|</li>", with: "\n", options: options)

		var s = String()
		s.reserveCapacity(preflight.count)
		var level = 0

		for char in preflight {
			if char == "<" {
				level += 1
			} else if char == ">" {
				level -= 1
			} else if level == 0 {
				s.append(char)
			}
		}

		return s.replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
	}

	func caseInsensitiveContains(_ string: String) -> Bool {
		return self.range(of: string, options: .caseInsensitive) != nil
	}

	var escapingSpecialXMLCharacters: String {
		CFXMLCreateStringByEscapingEntities(kCFAllocatorDefault, self as CFString, nil) as String
	}

	var strippingHTTPOrHTTPSScheme: String {
		self.strippingPrefix("http://").strippingPrefix("https://")
	}

}
