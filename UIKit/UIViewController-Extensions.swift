//
//  UIViewController+.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 4/15/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import UIKit

extension UIViewController {
	
	public func presentError(_ error: Error) {
		let errorTitle = NSLocalizedString("Error", comment: "Error")
		presentError(title: errorTitle, message: error.localizedDescription)
	}
	
	public func presentError(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let dismissTitle = NSLocalizedString("Dismiss", comment: "Dismiss")
		alertController.addAction(UIAlertAction(title: dismissTitle, style: .default))
		self.present(alertController, animated: true, completion: nil)
	}
	
}
