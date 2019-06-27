//
//  UIViewController+.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 4/15/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import UIKit

extension UIApplication {
	
	@available(*, deprecated, message: "Don't use this method.  It is going away very, very soon.")
	public func presentError(_ error: Error) {
		guard let controller = windows.first?.topViewController else {
			return
		}
		controller.presentError(error)
	}
	
}
