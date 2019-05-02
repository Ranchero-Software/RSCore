//
//  URLRequest+RSCore.swift
//  RSCore
//
//  Created by Maurice Parker on 5/2/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation

extension URLRequest {
	
	public init(url: URL, username: String, password: String) {

		self.init(url: url)

		let data = "\(username):\(password)".data(using: .utf8)
		let base64 = data?.base64EncodedString()
		let auth = "Basic \(base64 ?? "")"
		setValue(auth, forHTTPHeaderField: "Authorization")

	}
	
}
