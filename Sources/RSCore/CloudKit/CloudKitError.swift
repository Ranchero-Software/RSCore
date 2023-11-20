//
//  CloudKitError.swift
//  RSCore
//
//  Created by Maurice Parker on 3/26/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//
// Derived from https://github.com/caiyue1993/IceCream

import Foundation
import CloudKit

public class CloudKitError: LocalizedError {

	public let error: Error
	
	public init(_ error: Error) {
		self.error = error
	}
	
	public var errorDescription: String? {
		guard let ckError = error as? CKError else {
			return error.localizedDescription
		}
		
		switch ckError.code {
		case .alreadyShared:
			return String(localized: "cloudkit.error.already-shared", bundle: .module, comment: "Already Shared: a record or share cannot be saved because doing so would cause the same hierarchy of records to exist in multiple shares.")
		case .assetFileModified:
			return String(localized: "cloudkit.error.asset-file-modified", bundle: .module, comment: "Asset File Modified: the content of the specified asset file was modified while being saved.")
		case .assetFileNotFound:
			return String(localized: "cloudkit.error.asset-file-not-found", bundle: .module, comment: "Asset File Not Found: the specified asset file is not found.")
		case .badContainer:
			return String(localized: "cloudkit.error.bad-container", bundle: .module, comment: "Bad Container: the specified container is unknown or unauthorized.")
		case .badDatabase:
			return String(localized: "cloudkit.error.bad-database", bundle: .module, comment: "Bad Database: the operation could not be completed on the given database.")
		case .batchRequestFailed:
			return String(localized: "cloudkit.error.batch-request-failed", bundle: .module, comment: "Batch Request Failed: the entire batch was rejected.")
		case .changeTokenExpired:
			return String(localized: "cloudkit.error.change-token-expired", bundle: .module, comment: "Change Token Expired: the previous server change token is too old.")
		case .constraintViolation:
			return String(localized: "cloudkit.error.constraint-violation", bundle: .module, comment: "Constraint Violation: the server rejected the request because of a conflict with a unique field.")
		case .incompatibleVersion:
			return String(localized: "cloudkit.error.incompatible-version", bundle: .module, comment: "Incompatible Version: your app version is older than the oldest version allowed.")
		case .internalError:
			return String(localized: "cloudkit.error.internal-error", bundle: .module, comment: "Internal Error: a non-recoverable error was encountered by CloudKit.")
		case .invalidArguments:
			return String(localized: "cloudkit.error.invalid-arguments", bundle: .module, comment: "Invalid Arguments: the specified request contains bad information.")
		case .limitExceeded:
			return String(localized: "cloudkit.error.limit-exceeded", bundle: .module, comment: "Limit Exceeded: the request to the server is too large.")
		case .managedAccountRestricted:
			return String(localized: "cloudkit.error.managed-account-restriction", bundle: .module, comment: "Managed Account Restricted: the request was rejected due to a managed-account restriction.")
		case .missingEntitlement:
			return String(localized: "cloudkit.error.missing-entitlement", bundle: .module, comment: "Missing Entitlement: the app is missing a required entitlement.")
		case .networkUnavailable:
			return String(localized: "cloudkit.error.network-unavailable", bundle: .module, comment: "Network Unavailable: the internet connection appears to be offline.")
		case .networkFailure:
			return String(localized: "cloudkit.error.network-failure", bundle: .module, comment: "Network Failure: the internet connection appears to be offline.")
		case .notAuthenticated:
			return String(localized: "cloudkit.error.not-authenticated", bundle: .module, comment: "Not Authenticated: to use the iCloud account, you must enable iCloud Drive. Go to device Settings, sign in to iCloud, then in the app settings, be sure the iCloud Drive feature is enabled.")
		case .operationCancelled:
			return String(localized: "cloudkit.error.operation-canceled", bundle: .module, comment: "Operation Canceled: the operation was explicitly canceled.")
		case .partialFailure:
			return String(localized: "cloudkit.error.partial-failure", bundle: .module, comment: "Partial Failure: some items failed, but the operation succeeded overall.")
		case .participantMayNeedVerification:
			return String(localized: "cloudkit.error.participant-may-need-verification", bundle: .module, comment: "Participant May Need Verification: you are not a member of the share.")
		case .permissionFailure:
			return String(localized: "cloudkit.error.permission-failure", bundle: .module, comment: "Permission Failure: to use this app, you must enable iCloud Drive. Go to device Settings, sign in to iCloud, then in the app settings, be sure the iCloud Drive feature is enabled.")
		case .quotaExceeded:
			return String(localized: "cloudkit.error.quota-exceeded", bundle: .module, comment: "Quota Exceeded: saving would exceed your current iCloud storage quota.")
		case .referenceViolation:
			return String(localized: "cloudkit.error.reference-violation", bundle: .module, comment: "Reference Violation: the target of a record's parent or share reference was not found.")
		case .requestRateLimited:
			return String(localized: "cloudkit.error.request-rate-limited", bundle: .module, comment: "Request Rate Limited: transfers to and from the server are being rate limited at this time.")
		case .serverRecordChanged:
			return String(localized: "cloudkit.error.server-record-changed", bundle: .module, comment: "Server Record Changed: the record was rejected because the version on the server is different.")
		case .serverRejectedRequest:
			return String(localized: "cloudkit.error.server-rejected-request", bundle: .module, comment: "Server Rejected Request")
		case .serverResponseLost:
			return String(localized: "cloudkit.error.server-response-lost", bundle: .module, comment: "Server Response Lost")
		case .serviceUnavailable:
			return String(localized: "cloudkit.error.service-unavailable", bundle: .module, comment: "Service Unavailable: Please try again.")
		case .tooManyParticipants:
			return String(localized: "cloudkit.error.too-many-participants", bundle: .module, comment: "Too Many Participants: a share cannot be saved because too many participants are attached to the share.")
		case .unknownItem:
			return String(localized: "cloudkit.error.unknown-item", bundle: .module, comment: "Unknown Item: the specified record does not exist.")
		case .userDeletedZone:
			return String(localized: "cloudkit.error.user-deleted-zone", bundle: .module, comment: "User Deleted Zone: the user has deleted this zone from the settings UI.")
		case .zoneBusy:
			return String(localized: "cloudkit.error.zone-busy", bundle: .module, comment: "Zone Busy: the server is too busy to handle the zone operation.")
		case .zoneNotFound:
			return String(localized: "cloudkit.error.zone-not-found", bundle: .module, comment: "Zone Not Found: the specified record zone does not exist on the server.")
		default:
			return String(localized: "cloudkit.error.unhandled-error", bundle: .module, comment: "Unhandled Error.")
		}
	}
	
}
