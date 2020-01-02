//
//  Platform.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-02.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import os

struct Platform {
	static func dataFolder(forApplication appName: String?) -> URL? {
		do {
			var dataFolder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

			if let appName = appName ?? Bundle.main.infoDictionary?["CFBundleExecutable"] as? String {

				dataFolder = dataFolder.appendingPathComponent(appName)

				try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true, attributes: nil)
			}

			return dataFolder
		} catch {
			print("DataFolder error:", error)
		}

		return nil
	}

	static func dataFile(forApplication appName: String?, filename: String) -> URL? {
		let dataFolder = self.dataFolder(forApplication: appName)
		return dataFolder?.appendingPathComponent(filename)
	}

	static func dataSubfolder(forApplication appName: String?, folderName: String) -> URL? {
		guard let dataFolder = dataFile(forApplication: appName, filename: folderName) else {
			return nil
		}

		do {
			try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true, attributes: nil)
			return dataFolder
		} catch {
			print("DataSubfolder error:", error)
		}

		return nil
	}

	static func dataSubfolderFile(forApplication appName: String?, folderName: String, filename: String) -> URL? {
		let dataFolder = dataSubfolder(forApplication: appName, folderName: folderName)
		return dataFolder?.appendingPathComponent(filename)
	}
}
