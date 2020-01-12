//
//  SendToBlogEditorApp.swift
//  RSCore
//
//  Created by Nate Weaver on 2020-01-04.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

public struct SendToBlogEditorApp {

	private let targetDescriptor: NSAppleEventDescriptor
	private let title: String?
	private let body: String?
	private let summary: String?
	private let link: String?
	private let permalink: String?
	private let subject: String?
	private let creator: String?
	private let commentsURL: String?
	private let guid: String?
	private let sourceName: String?
	private let sourceHomeURL: String?
	private let sourceFeedURL: String?

	func send() {

		let appleEvent = NSAppleEventDescriptor.appleEvent(withEventClass: .editDataItemAppleEventClass, eventID: .editDataItemAppleEventID, targetDescriptor: targetDescriptor, returnID: .autoGenerate, transactionID: .any)

		appleEvent.setParam(paramDescriptor, forKeyword: keyDirectObject)

		let _ = try? appleEvent.sendEvent(options: [.noReply, .canSwitchLayer, .alwaysInteract], timeout: .AEDefaultTimeout)

	}

}

private extension SendToBlogEditorApp {

	var paramDescriptor: NSAppleEventDescriptor {
		let descriptor = NSAppleEventDescriptor.record()

		add(toDescriptor: descriptor, value: title, keyword: .dataItemTitle)
		add(toDescriptor: descriptor, value: body, keyword: .dataItemDescription)
		add(toDescriptor: descriptor, value: summary, keyword: .dataItemSummary)
		add(toDescriptor: descriptor, value: link, keyword: .dataItemLink)
		add(toDescriptor: descriptor, value: permalink, keyword: .dataItemPermalink)
		add(toDescriptor: descriptor, value: subject, keyword: .dataItemSubject)
		add(toDescriptor: descriptor, value: creator, keyword: .dataItemCreator)
		add(toDescriptor: descriptor, value: commentsURL, keyword: .dataItemCommentsURL)
		add(toDescriptor: descriptor, value: guid, keyword: .dataItemGUID)
		add(toDescriptor: descriptor, value: sourceName, keyword: .dataItemSourceName)
		add(toDescriptor: descriptor, value: sourceHomeURL, keyword: .dataItemSourceHomeURL)
		add(toDescriptor: descriptor, value: sourceFeedURL, keyword: .dataItemSourceFeedURL)

		return descriptor
	}

	func add(toDescriptor descriptor: NSAppleEventDescriptor, value: String?, keyword: AEKeyword) {

		guard let value = value else { return }

		let stringDescriptor = NSAppleEventDescriptor.init(string: value)
		descriptor.setDescriptor(stringDescriptor, forKeyword: keyword)
	}
}

private extension AEEventClass {

	static let editDataItemAppleEventClass = "EBlg".fourCharCode

}

private extension AEEventID {

	static let editDataItemAppleEventID = "oitm".fourCharCode

}

private extension AEKeyword {

	static let dataItemTitle = "titl".fourCharCode
	static let dataItemDescription = "desc".fourCharCode
	static let dataItemSummary = "summ".fourCharCode
	static let dataItemLink = "link".fourCharCode
	static let dataItemPermalink = "plnk".fourCharCode
	static let dataItemSubject = "subj".fourCharCode
	static let dataItemCreator = "crtr".fourCharCode
	static let dataItemCommentsURL = "curl".fourCharCode
	static let dataItemGUID = "guid".fourCharCode
	static let dataItemSourceName = "snam".fourCharCode
	static let dataItemSourceHomeURL = "hurl".fourCharCode
	static let dataItemSourceFeedURL = "furl".fourCharCode

}

private extension AEReturnID {

	static let autoGenerate = AEReturnID(kAutoGenerateReturnID)
}

private extension AETransactionID {

	static let any = AETransactionID(kAnyTransactionID)

}

private extension TimeInterval {

	static let AEDefaultTimeout = TimeInterval(kAEDefaultTimeout)

}
