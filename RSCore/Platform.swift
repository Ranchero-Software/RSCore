//
//  Platform.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-02.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import os

public struct Platform {
	static func dataFolder(forApplication appName: String?) -> URL? {
		do {
			var dataFolder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

			if let appName = appName ?? Bundle.main.infoDictionary?["CFBundleExecutable"] as? String {

				dataFolder = dataFolder.appendingPathComponent(appName)

				try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true, attributes: nil)
			}

			return dataFolder
		} catch {
			os_log(.error, log: .default, "Platform.dataFolder error: %@", error.localizedDescription)
		}

		return nil
	}

	static func dataFile(forApplication appName: String?, filename: String) -> URL? {
		let dataFolder = self.dataFolder(forApplication: appName)
		return dataFolder?.appendingPathComponent(filename)
	}

	public static func dataSubfolder(forApplication appName: String?, folderName: String) -> String? {
		guard let dataFolder = dataFile(forApplication: appName, filename: folderName) else {
			return nil
		}

		do {
			try FileManager.default.createDirectory(at: dataFolder, withIntermediateDirectories: true, attributes: nil)
			return dataFolder.path
		} catch {
			os_log(.error, log: .default, "Platform.dataSubfolder error: %@", error.localizedDescription)
		}

		return nil
	}
}
