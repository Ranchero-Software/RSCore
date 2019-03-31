//
//  Array+RSCore.swift
//  RSCore
//
//  Created by Brent Simmons on 2/17/18.
//  Copyright © 2018 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public extension Array {

	func firstElementPassingTest( _ test: (Element) -> Bool) -> Element? {

		guard let index = self.firstIndex(where: test) else {
			return nil
		}
		return self[index]
	}
}
