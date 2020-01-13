//
//  Data+RSCore.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-02.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import CryptoKit

public extension Data {

	var md5Hash: Data? {
		if #available(macOS 10.15, *) {
			let digest = Insecure.MD5.hash(data: self)
			return Data(digest)
		}

		return nil;
	}

	var md5String: String? {
		return md5Hash?.hexadecimalString
	}

	// http://www.w3.org/TR/PNG/#5PNG-file-signature : "The first eight bytes of a PNG datastream always contain the following (decimal) values: 137 80 78 71 13 10 26 10"

	private static let pngHeader = Data([137, 80, 78, 71, 13, 10, 26, 10])

	var isPNG: Bool {
		return prefix(8) == .pngHeader
	}

	// http://www.onicos.com/staff/iz/formats/gif.html

	private static let gif89Header = "GIF89a".data(using: .ascii)
	private static let gif87Header = "GIF87a".data(using: .ascii)

	var isGIF: Bool {
		let prefix = self.prefix(6)
		return prefix == .gif89Header || prefix == .gif87Header
	}

	private static let jpegHeader = "JFIF".data(using: .ascii)
	private static let exifHeader = "Exif".data(using: .ascii)

	var isJPEG: Bool {
		let signature = self[6..<10]
		return signature == .jpegHeader || signature == .exifHeader
	}

	var isProbablyHTML: Bool {

		if !self.contains("<".utf8.first!) || !self.contains(">".utf8.first!) {
			return false
		}

		let tags = ["html", "body"]

		if tags.reduce(true, { (lastResult, tag) -> Bool in
			return lastResult
				&& (self.range(of: tag.data(using: .utf8)!) != nil
					|| self.range(of: tag.uppercased().data(using: .utf8)!) != nil)
		}) {
			return true
		}

		if tags.reduce(true, { (lastResult, tag) -> Bool in
			return lastResult
				&& (self.range(of: tag.data(using: .utf16LittleEndian)!) != nil
					|| self.range(of: tag.uppercased().data(using: .utf16LittleEndian)!) != nil)
		}) {
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
