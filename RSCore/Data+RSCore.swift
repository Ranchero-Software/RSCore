//
//  Data+RSCore.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-02.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif
import CommonCrypto

public extension Data {

	/// The MD5 hash of the data.
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

	/// The MD5 has of the data, as a hexadecimal string.
	var md5String: String? {
		return md5Hash.hexadecimalString
	}


	/// Image signature constants.
	private enum ImageSignature {

		/// The signature for PNG data.
		///
		/// [PNG signature](http://www.w3.org/TR/PNG/#5PNG-file-signature)\:
		/// "The first eight bytes of a PNG datastream always contain the following (decimal) values:
		/// ```
		/// 137 80 78 71 13 10 26 10
		/// ```
		static let png = Data([137, 80, 78, 71, 13, 10, 26, 10])

		/// The signature for GIF 89a data.
		///
		/// [http://www.onicos.com/staff/iz/formats/gif.html](http://www.onicos.com/staff/iz/formats/gif.html)
		static let gif89a = "GIF89a".data(using: .ascii)
		/// The signature for GIF 87a data.
		///
		/// [http://www.onicos.com/staff/iz/formats/gif.html](http://www.onicos.com/staff/iz/formats/gif.html)
		static let gif87a = "GIF87a".data(using: .ascii)

		/// The signature for standard JPEG data.
		///
		/// JPEG signatures start at byte 6.
		static let jfif = "JFIF".data(using: .ascii)

		/// The signature for Exif JPEG data.
		///
		/// JPEG signatures start at byte 6.
		static let exif = "Exif".data(using: .ascii)
	}

	/// Returns `true` if the data begins with the PNG signature.
	var isPNG: Bool {
		return prefix(8) == ImageSignature.png
	}

	/// Returns `true` if the data begins with a valid GIF signature.
	var isGIF: Bool {
		let prefix = self.prefix(6)
		return prefix == ImageSignature.gif89a || prefix == ImageSignature.gif87a
	}

	/// Returns `true` if the data contains a valid JPEG signature.
	var isJPEG: Bool {
		let signature = self[6..<10]
		return signature == ImageSignature.jfif || signature == ImageSignature.exif
	}

	/// Returns `true` if the data is an image (PNG, JPEG, or GIF).
	var isImage: Bool {
		return  isPNG || isJPEG || isGIF
	}

	/// Constants for `isProbablyHTML`.
	private enum RSSearch {

		static let lessThan = "<".utf8.first!
		static let greaterThan = ">".utf8.first!

		/// Tags in UTF-8/ASCII format.
		enum UTF8 {
			static let lowercaseHTML = "html".data(using: .utf8)!
			static let lowercaseBody = "body".data(using: .utf8)!
			static let uppercaseHTML = "HTML".data(using: .utf8)!
			static let uppercaseBody = "HTML".data(using: .utf8)!
		}

		/// Tags in UTF-16 format.
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
	/// which for ASCII codepoints is essentially ASCII characters with nulls in between.
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

	/// A representation of the data as a hexadecimal string.
	var hexadecimalString: String? {
		if count == 0 {
			return nil
		}

		// Special case for MD5
		if count == 16 {
			return String(format: "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15])
		}

		return reduce("") { $0 + String(format: "%02x", $1) }
	}

}
