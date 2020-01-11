//
//  Calendar+RSCore.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-01.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public extension Calendar {

	static let cached: Calendar = .autoupdatingCurrent

	static func dateIsToday(_ date: Date) -> Bool {
		return cached.isDateInToday(date)
	}

	static var startOfToday = {
		cached.startOfDay(for: Date())
	}
	
}
