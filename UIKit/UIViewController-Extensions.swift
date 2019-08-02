//
//  UIViewController+.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 4/15/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import UIKit

extension UIViewController {
	
	public func addChildAndPinView(_ controller: UIViewController) {
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(controller.view)
		
		NSLayoutConstraint.activate([
			controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			controller.view.topAnchor.constraint(equalTo: view.topAnchor),
			controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		addChild(controller)
	}
	
	public func replaceChildAndPinView(_ controller: UIViewController) {
		view.subviews.forEach { $0.removeFromSuperview() }
		children.forEach { $0.removeFromParent() }
		addChildAndPinView(controller)
	}
	
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
