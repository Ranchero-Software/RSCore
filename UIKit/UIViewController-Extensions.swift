//
//  UIViewController-Extensions.swift
//  NetNewsWire
//
//  Created by Maurice Parker on 4/15/19.
//  Copyright © 2019 Ranchero Software. All rights reserved.
//

import UIKit
import SwiftUI

extension UIViewController {
	
	// MARK: Autolayout
	
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
	
	// MARK: Error Handling
	
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

// MARK: SwiftUI

public struct ViewControllerHolder {
	public weak var value: UIViewController?
}

public struct ViewControllerKey: EnvironmentKey {
	public static var defaultValue: ViewControllerHolder { return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController ) }
}

extension EnvironmentValues {
	public var viewController: UIViewController? {
		get { return self[ViewControllerKey.self].value }
		set { self[ViewControllerKey.self].value = newValue }
	}
}

extension UIViewController {
	public func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
		let controller = UIHostingController(rootView: AnyView(EmptyView()))
		controller.modalPresentationStyle = style
		controller.rootView = AnyView(
			builder().environment(\.viewController, controller)
		)
		self.present(controller, animated: true, completion: nil)
	}
}

