//
//  FileManager+RSCore.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-02.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public extension FileManager {

	func fileIsFolder(atPath path: String) -> Bool {
		let url = URL(fileURLWithPath: path)

		if let values = try? url.resourceValues(forKeys: [.isDirectoryKey]) {
			return values.isDirectory ?? false
		}

		return false
	}

	func copyFiles(fromFolder source: String, toFolder destination: String) throws {
		assert(fileIsFolder(atPath: source))
		assert(fileIsFolder(atPath: destination))

		let sourceURL = URL(fileURLWithPath: source)
		let destinationURL = URL(fileURLWithPath: destination)

		let filenames = try self.contentsOfDirectory(atPath: source)

		for oneFilename in filenames {
			if oneFilename.hasPrefix(".") {
				continue
			}

			let sourceFile = sourceURL.appendingPathComponent(oneFilename)
			let destinationFile = destinationURL.appendingPathComponent(oneFilename)

			try copyFile(atPath: sourceFile.path, toPath: destinationFile.path, overwriting: true)
		}

	}

	func filenames(inFolder folder: String) -> [String]? {
		assert(fileIsFolder(atPath: folder))

		guard fileIsFolder(atPath: folder) else {
			return []
		}

		return try? self.contentsOfDirectory(atPath: folder)
	}

	func filePaths(inFolder folder: String) -> [String]? {
		guard let filenames = self.filenames(inFolder: folder) else {
			return nil
		}
		
		let url = URL(fileURLWithPath: folder)
		return filenames.map { url.appendingPathComponent($0).path }
	}

}

private extension FileManager {

	func copyFile(atPath source: String, toPath destination: String, overwriting: Bool) throws {
		assert(fileExists(atPath: source))

		if fileExists(atPath: destination) {
			if (overwriting) {
				try removeItem(atPath: destination)
			}
		}

		try copyItem(atPath: source, toPath: destination)
	}

}
