//
//  Data+RSCore.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-02.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

public extension Data {

	/// Compute the MD5 hash of the data.
	var md5Hash: Data {

		if #available(macOS 10.15, *) {
			let digest = Insecure.MD5.hash(data: self)
			return Data(digest)
		} else {
			let len = Int(CC_MD5_DIGEST_LENGTH)
			let md = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: len)

			let _ = self.withUnsafeBytes {
				CC_MD5($0.baseAddress, numericCast($0.count), md)
			}

			return Data(bytes: md, count: len)
		}

	}

	var md5String: String? {
		return md5Hash.hexadecimalString
	}

	/// http://www.w3.org/TR/PNG/#5PNG-file-signature : "The first eight bytes of a PNG datastream always contain the following (decimal) values: 137 80 78 71 13 10 26 10"

	private static let pngSignature = Data([137, 80, 78, 71, 13, 10, 26, 10])


	/// Returns `true` if the data begins with the PNG signature.
	var isPNG: Bool {
		return prefix(8) == .pngSignature
	}


	private static let gif89Signature = "GIF89a".data(using: .ascii)
	private static let gif87Signature = "GIF87a".data(using: .ascii)

	/// Returns `true` if the data begins with a valid GIF signature.
	///
	/// [http://www.onicos.com/staff/iz/formats/gif.html](http://www.onicos.com/staff/iz/formats/gif.html)
	var isGIF: Bool {
		let prefix = self.prefix(6)
		return prefix == .gif89Signature || prefix == .gif87Signature
	}

	private static let jpegSignature = "JFIF".data(using: .ascii)
	private static let exifSignature = "Exif".data(using: .ascii)

	/// Returns `true` if the data contains a valid JPEG signature.
	var isJPEG: Bool {
		let signature = self[6..<10]
		return signature == .jpegSignature || signature == .exifSignature
	}

	/// Constants for `isProbablyHTML`.
	private enum RSSearch {

		static let lessThan = "<".utf8.first!
		static let greaterThan = ">".utf8.first!

		enum UTF8 {
			static let lowercaseHTML = "html".data(using: .utf8)!
			static let lowercaseBody = "body".data(using: .utf8)!
			static let uppercaseHTML = "HTML".data(using: .utf8)!
			static let uppercaseBody = "HTML".data(using: .utf8)!
		}

		enum UTF16 {
			static let lowercaseHTML = "html".data(using: .utf16LittleEndian)!
			static let lowercaseBody = "body".data(using: .utf16LittleEndian)!
			static let uppercaseHTML = "HTML".data(using: .utf16LittleEndian)!
			static let uppercaseBody = "HTML".data(using: .utf16LittleEndian)!
		}

	}

	/// Returns `true` if the data looks like it could be HTML.
	///
	/// Advantage is taken of the fact that most common encodings are ASCII-compatible, aside from UTF-16,
	/// which for ASCII codepoints is basically ASCII characters with nulls in between.
	///
	/// An uncommon exception is any EBCDIC-derived encoding.
	var isProbablyHTML: Bool {

		if !self.contains(RSSearch.lessThan) || !self.contains(RSSearch.greaterThan) {
			return false
		}

		if (self.range(of: RSSearch.UTF8.lowercaseHTML) != nil || self.range(of: RSSearch.UTF8.uppercaseHTML) != nil)
			&& (self.range(of: RSSearch.UTF8.lowercaseBody) != nil || self.range(of: RSSearch.UTF8.uppercaseBody) != nil) {
			return true
		}

		if (self.range(of: RSSearch.UTF16.lowercaseHTML) != nil || self.range(of: RSSearch.UTF16.uppercaseHTML) != nil)
			&& (self.range(of: RSSearch.UTF16.lowercaseBody) != nil || self.range(of: RSSearch.UTF16.uppercaseBody) != nil) {
			return true
		}

		return false
	}

	var hexadecimalString: String? {
		if count == 0 {
			return nil
		}

		if count == 16 {
			return String(format: "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15])
		}

		return reduce("") { $0 + String(format: "%02x", $1) }
	}

}

extension String.Encoding {
	/// A superset of GB-2312.
	static let GB_18030_2000 = Self.fromCFStringEncodingExt(.GB_18030_2000)
	static let big5 = Self.fromCFStringEncodingExt(.big5)
	static let koreanEUC = Self.fromCFStringEncodingExt(.EUC_KR)

	/// Converts a `CFStringEncodings` (note trailing 's') to a `String.Encoding`.
	static func fromCFStringEncodingExt(_ cfEncoding: CFStringEncodings) -> String.Encoding {
		let nsEncoding =  CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
		return String.Encoding(rawValue: nsEncoding)
	}
}
