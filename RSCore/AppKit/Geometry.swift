//
//  Geometry.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-01.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public extension CGRect {
	func centeredVertically(in containerRect: CGRect) -> CGRect {
		var r = self;
		r.origin.y = containerRect.midY - (r.height / 2.0);
		r = r.integral;
		r.size = self.size;
		return r;
	}

	func centeredHorizontally(in containerRect: CGRect) -> CGRect {
		var r = self;
		r.origin.x = containerRect.midX - (r.width / 2.0);
		r = r.integral;
		r.size = self.size;
		return r;
	}

	func centered(in containerRect: CGRect) -> CGRect {
		return self.centeredHorizontally(in: self.centeredVertically(in: containerRect))
	}
}
