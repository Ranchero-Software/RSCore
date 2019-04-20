//
//  UIView-Extensions.swift
//  RSCore
//
//  Created by Maurice Parker on 4/20/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import UIKit

extension UIView {
	
	public func setFrameIfNotEqual(_ rect: CGRect) {
		if !self.frame.equalTo(rect) {
			self.frame = rect
		}
	}
	
}
