//
//  UITableView-Extensions.swift
//  RSCoreiOS
//
//  Created by Maurice Parker on 9/6/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation

extension UITableView {
	
	/**
	Selects a row and scrolls it to the middle if it is not visible
	*/
	public func selectRowAndScrollIfNotVisible(at indexPath: IndexPath, animated: Bool) {
		if let visibleIndexPaths = indexPathsForRows(in: safeAreaLayoutGuide.layoutFrame) {
			if visibleIndexPaths.contains(indexPath) {
				selectRow(at: indexPath, animated: animated, scrollPosition: .none)
			} else {
				selectRow(at: indexPath, animated: animated, scrollPosition: .middle)
			}
		}
	}
	
}
