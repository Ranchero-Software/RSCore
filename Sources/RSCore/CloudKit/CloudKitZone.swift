//
//  CloudKitZone.swift
//  RSCore
//
//  Created by Maurice Parker on 3/21/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import CloudKit
import os.log

public enum CloudKitZoneError: LocalizedError {
	case userDeletedZone
	case corruptAccount
	case unknown
	
	public var errorDescription: String? {
		switch self {
		case .userDeletedZone:
			return NSLocalizedString("The iCloud data was deleted.  Please remove the application iCloud account and add it again to continue using the application's iCloud support.", comment: "User deleted zone.")
		case .corruptAccount:
			return NSLocalizedString("There is an unrecoverable problem with your application iCloud account. Please make sure you have iCloud and iCloud Drive enabled in System Preferences. Then remove the application iCloud account and add it again.", comment: "Corrupt account.")
		default:
			return NSLocalizedString("An unexpected CloudKit error occurred.", comment: "An unexpected CloudKit error occurred.")
		}
	}
}

public protocol CloudKitZoneDelegate: AnyObject {
	func cloudKitWasChanged(updated: [CKRecord], deleted: [CloudKitRecordKey], completion: @escaping (Result<Void, Error>) -> Void);
}

public typealias CloudKitRecordKey = (recordType: CKRecord.RecordType, recordID: CKRecord.ID)

public protocol CloudKitZone: AnyObject, Logging {
	
	static var qualityOfService: QualityOfService { get }

	var zoneID: CKRecordZone.ID { get }

	var container: CKContainer? { get }
	var database: CKDatabase? { get }
	var delegate: CloudKitZoneDelegate? { get set }

	/// Reset the change token used to determine what point in time we are doing changes fetches
	func resetChangeToken()

	/// Generates a new CKRecord.ID using a UUID for the record's name
	func generateRecordID() -> CKRecord.ID
	
	/// Subscribe to changes at a zone level
	func subscribeToZoneChanges()
	
}

public extension CloudKitZone {
	
	// My observation has been that QoS is treated differently for CloudKit operations on macOS vs iOS.
	// .userInitiated is too aggressive on iOS and can lead the UI slowing down and appearing to block.
	// .default (or lower) on macOS will sometimes hang for extended periods of time and appear to hang.
	static var qualityOfService: QualityOfService {
		#if os(macOS) || targetEnvironment(macCatalyst)
		return .userInitiated
		#else
		return .default
		#endif
	}
	
	var oldChangeTokenKey: String {
		return "cloudkit.server.token.\(zoneID.zoneName)"
	}

	var changeTokenKey: String {
		return "cloudkit.server.token.\(zoneID.zoneName).\(zoneID.ownerName)"
	}

	var changeToken: CKServerChangeToken? {
		get {
			guard let tokenData = UserDefaults.standard.object(forKey: changeTokenKey) as? Data else { return nil }
			return try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: tokenData)
		}
		set {
			guard let token = newValue, let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false) else {
				UserDefaults.standard.removeObject(forKey: changeTokenKey)
				return
			}
			UserDefaults.standard.set(data, forKey: changeTokenKey)
		}
	}

	/// Moves the change token to the new key name.  This can eventually be removed.
	func migrateChangeToken() {
		if let tokenData = UserDefaults.standard.object(forKey: oldChangeTokenKey) as? Data,
		   let oldChangeToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: tokenData) {
			changeToken = oldChangeToken
			UserDefaults.standard.removeObject(forKey: oldChangeTokenKey)
		}
	}
	
	/// Reset the change token used to determine what point in time we are doing changes fetches
	func resetChangeToken() {
		changeToken = nil
	}
	
	func generateRecordID() -> CKRecord.ID {
		return CKRecord.ID(recordName: UUID().uuidString, zoneID: zoneID)
	}

	func retryIfPossible(after: Double, block: @escaping () -> ()) {
		let delayTime = DispatchTime.now() + after
		DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
			block()
		})
	}
	
	func receiveRemoteNotification(userInfo: [AnyHashable : Any], incrementalFetch: Bool = true, completion: @escaping () -> Void) {
		let note = CKRecordZoneNotification(fromRemoteNotificationDictionary: userInfo)
		guard note?.recordZoneID?.zoneName == zoneID.zoneName else {
			completion()
			return
		}
		
		fetchChangesInZone(incremental: incrementalFetch) { result in
			if case .failure(let error) = result {
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone remote notification fetch error: \(error.localizedDescription, privacy: .public)")
			}
			completion()
		}
	}

	/// Retrieves the zone record for this zone only. If the record isn't found it will be created.
	func fetchZoneRecord(completion: @escaping (Result<CKRecordZone?, Error>) -> Void) {
		let op = CKFetchRecordZonesOperation(recordZoneIDs: [zoneID])
		op.qualityOfService = Self.qualityOfService

		op.fetchRecordZonesCompletionBlock = { [weak self] (zoneRecords, error) in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
			case .success:
				completion(.success(zoneRecords?[self.zoneID]))
			case .zoneNotFound, .userDeletedZone:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.fetchZoneRecord(completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone fetch changes retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.fetchZoneRecord(completion: completion)
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
			
		}

		database?.add(op)
	}

	/// Creates the zone record
	func createZoneRecord(completion: @escaping (Result<Void, Error>) -> Void) {
		guard let database = database else {
			completion(.failure(CloudKitZoneError.unknown))
			return
		}

		database.save(CKRecordZone(zoneID: zoneID)) { (recordZone, error) in
			if let error = error {
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error)))
				}
			} else {
				DispatchQueue.main.async {
					completion(.success(()))
				}
			}
		}
	}

	/// Subscribes to zone changes
	func subscribeToZoneChanges() {
		let subscription = CKRecordZoneSubscription(zoneID: zoneID)
        
		let info = CKSubscription.NotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        
		save(subscription) { result in
			if case .failure(let error) = result {
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) subscribe to changes error: \(error.localizedDescription, privacy: .public)")
			}
		}
    }
		
	/// Issue a CKQuery and return the resulting CKRecords.
	func query(_ ckQuery: CKQuery, desiredKeys: [String]? = nil, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
		var records = [CKRecord]()
		
		let op = CKQueryOperation(query: ckQuery)
		op.qualityOfService = Self.qualityOfService
		
		if let desiredKeys = desiredKeys {
			op.desiredKeys = desiredKeys
		}
		
		op.recordFetchedBlock = { record in
			records.append(record)
		}
		
		op.queryCompletionBlock = { [weak self] (cursor, error) in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
            case .success:
				DispatchQueue.main.async {
					if let cursor = cursor {
						self.query(cursor: cursor, desiredKeys: desiredKeys, carriedRecords: records, completion: completion)
					} else {
						completion(.success(records))
					}
				}
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.query(ckQuery, desiredKeys: desiredKeys, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone query retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.query(ckQuery, desiredKeys: desiredKeys, completion: completion)
				}
			case .userDeletedZone:
				DispatchQueue.main.async {
					completion(.failure(CloudKitZoneError.userDeletedZone))
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}
		
		database?.add(op)
	}
	
	/// Query CKRecords using a CKQuery Cursor
	func query(cursor: CKQueryOperation.Cursor, desiredKeys: [String]? = nil, carriedRecords: [CKRecord], completion: @escaping (Result<[CKRecord], Error>) -> Void) {
		var records = carriedRecords
		
		let op = CKQueryOperation(cursor: cursor)
		op.qualityOfService = Self.qualityOfService
		
		if let desiredKeys = desiredKeys {
			op.desiredKeys = desiredKeys
		}
		
		op.recordFetchedBlock = { record in
			records.append(record)
		}
		
		op.queryCompletionBlock = { [weak self] (newCursor, error) in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
			case .success:
				DispatchQueue.main.async {
					if let newCursor = newCursor {
						self.query(cursor: newCursor, desiredKeys: desiredKeys, carriedRecords: records, completion: completion)
					} else {
						completion(.success(records))
					}
				}
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.query(cursor: cursor, desiredKeys: desiredKeys, carriedRecords: records, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone query retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.query(cursor: cursor, desiredKeys: desiredKeys, carriedRecords: records, completion: completion)
				}
			case .userDeletedZone:
				DispatchQueue.main.async {
					completion(.failure(CloudKitZoneError.userDeletedZone))
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}

		database?.add(op)
	}
	

	/// Fetch a CKRecord by using its externalID
	func fetch(externalID: String?, completion: @escaping (Result<CKRecord, Error>) -> Void) {
		guard let externalID = externalID else {
			completion(.failure(CloudKitZoneError.corruptAccount))
			return
		}

		let recordID = CKRecord.ID(recordName: externalID, zoneID: zoneID)
		
		database?.fetch(withRecordID: recordID) { [weak self] record, error in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
            case .success:
				DispatchQueue.main.async {
					if let record = record {
						completion(.success(record))
					} else {
						completion(.failure(CloudKitZoneError.unknown))
					}
				}
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.fetch(externalID: externalID, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone fetch retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.fetch(externalID: externalID, completion: completion)
				}
			case .userDeletedZone:
				DispatchQueue.main.async {
					completion(.failure(CloudKitZoneError.userDeletedZone))
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}
	}
	
	/// Save the CKRecord
	func save(_ record: CKRecord, completion: @escaping (Result<Void, Error>) -> Void) {
		modify(recordsToSave: [record], recordIDsToDelete: [], completion: completion)
	}
	
	/// Save the CKRecords
	func save(_ records: [CKRecord], completion: @escaping (Result<Void, Error>) -> Void) {
		modify(recordsToSave: records, recordIDsToDelete: [], completion: completion)
	}
	
	/// Saves or modifies the records as long as they are unchanged relative to the local version
	func saveIfNew(_ records: [CKRecord], completion: @escaping (Result<Void, Error>) -> Void) {
		let op = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: [CKRecord.ID]())
		op.savePolicy = .ifServerRecordUnchanged
		op.isAtomic = false
		op.qualityOfService = Self.qualityOfService
		
		op.modifyRecordsCompletionBlock = { [weak self] (_, _, error) in
			
			guard let self = self else { return }
			
			switch CloudKitZoneResult.resolve(error) {
			case .success, .partialFailure:
				self.logger.debug("Saved \(records.count, privacy: .public) new records.")
				DispatchQueue.main.async {
					completion(.success(()))
				}
				
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.saveIfNew(records, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
				
			case .userDeletedZone:
				DispatchQueue.main.async {
					completion(.failure(CloudKitZoneError.userDeletedZone))
				}
				
			case .retry(let timeToWait):
				self.retryIfPossible(after: timeToWait) {
					self.saveIfNew(records, completion: completion)
				}
				
			case .limitExceeded:

				var chunkedRecords = records.chunked(into: 200)

				func saveChunksIfNew() {
					if let records = chunkedRecords.popLast() {
						self.saveIfNew(records) { result in
							switch result {
							case .success:
                                self.logger.info("Saved \(records.count, privacy: .public) chunked new records.")
								saveChunksIfNew()
							case .failure(let error):
								completion(.failure(error))
							}
						}
					} else {
						completion(.success(()))
					}
				}
				
				saveChunksIfNew()
				
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}

		database?.add(op)
	}

	/// Save the CKSubscription
	func save(_ subscription: CKSubscription, completion: @escaping (Result<CKSubscription, Error>) -> Void) {
		database?.save(subscription) { [weak self] savedSubscription, error in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
			case .success:
				DispatchQueue.main.async {
					completion(.success((savedSubscription!)))
				}
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.save(subscription, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone save subscription retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.save(subscription, completion: completion)
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}
	}
	
	/// Delete CKRecords using a CKQuery
	func delete(ckQuery: CKQuery, completion: @escaping (Result<Void, Error>) -> Void) {
		
		var records = [CKRecord]()
		
		let op = CKQueryOperation(query: ckQuery)
		op.qualityOfService = Self.qualityOfService
		op.recordFetchedBlock = { record in
			records.append(record)
		}
		
		op.queryCompletionBlock = { [weak self] (cursor, error) in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}


			if let cursor = cursor {
				self.delete(cursor: cursor, carriedRecords: records, completion: completion)
			} else {
				guard !records.isEmpty else {
					DispatchQueue.main.async {
						completion(.success(()))
					}
					return
				}
				
				let recordIDs = records.map { $0.recordID }
				self.modify(recordsToSave: [], recordIDsToDelete: recordIDs, completion: completion)
			}
			
		}
		
		database?.add(op)
	}
	
	/// Delete CKRecords using a CKQuery
	func delete(cursor: CKQueryOperation.Cursor, carriedRecords: [CKRecord], completion: @escaping (Result<Void, Error>) -> Void) {
		
		var records = [CKRecord]()
		
		let op = CKQueryOperation(cursor: cursor)
		op.qualityOfService = Self.qualityOfService
		op.recordFetchedBlock = { record in
			records.append(record)
		}
		
		op.queryCompletionBlock = { [weak self] (cursor, error) in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			records.append(contentsOf: carriedRecords)
			
			if let cursor = cursor {
				self.delete(cursor: cursor, carriedRecords: records, completion: completion)
			} else {
				let recordIDs = records.map { $0.recordID }
				self.modify(recordsToSave: [], recordIDsToDelete: recordIDs, completion: completion)
			}
			
		}
		
		database?.add(op)
	}
	
	/// Delete a CKRecord using its recordID
	func delete(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
		modify(recordsToSave: [], recordIDsToDelete: [recordID], completion: completion)
	}
		
	/// Delete CKRecords
	func delete(recordIDs: [CKRecord.ID], completion: @escaping (Result<Void, Error>) -> Void) {
		modify(recordsToSave: [], recordIDsToDelete: recordIDs, completion: completion)
	}
		
	/// Delete a CKRecord using its externalID
	func delete(externalID: String?, completion: @escaping (Result<Void, Error>) -> Void) {
		guard let externalID = externalID else {
			completion(.failure(CloudKitZoneError.corruptAccount))
			return
		}

		let recordID = CKRecord.ID(recordName: externalID, zoneID: zoneID)
		modify(recordsToSave: [], recordIDsToDelete: [recordID], completion: completion)
	}
	
	/// Delete a CKSubscription
	func delete(subscriptionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
		database?.delete(withSubscriptionID: subscriptionID) { [weak self] _, error in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
			case .success:
				DispatchQueue.main.async {
					completion(.success(()))
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone delete subscription retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.delete(subscriptionID: subscriptionID, completion: completion)
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}
	}

	/// Modify and delete the supplied CKRecords and CKRecord.IDs
	func modify(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecord.ID], completion: @escaping (Result<Void, Error>) -> Void) {
		guard !(recordsToSave.isEmpty && recordIDsToDelete.isEmpty) else {
			DispatchQueue.main.async {
				completion(.success(()))
			}
			return
		}

		let op = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
		op.savePolicy = .changedKeys
		op.isAtomic = true
		op.qualityOfService = Self.qualityOfService

		op.modifyRecordsCompletionBlock = { [weak self] (_, _, error) in
			
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
			case .success:
				DispatchQueue.main.async {
					self.logger.debug("Updated \(recordsToSave.count, privacy: .public) records and deleted \(recordIDsToDelete.count, privacy: .public) records.")
					completion(.success(()))
				}
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.modify(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .userDeletedZone:
				DispatchQueue.main.async {
					completion(.failure(CloudKitZoneError.userDeletedZone))
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone modify retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.modify(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete, completion: completion)
				}
			case .limitExceeded:
				var recordToSaveChunks = recordsToSave.chunked(into: 200)
				var recordIDsToDeleteChunks = recordIDsToDelete.chunked(into: 200)

				func saveChunks(completion: @escaping (Result<Void, Error>) -> Void) {
					if !recordToSaveChunks.isEmpty {
						let records = recordToSaveChunks.removeFirst()
						self.modify(recordsToSave: records, recordIDsToDelete: []) { result in
							switch result {
							case .success:
                                self.logger.info("Saved \(records.count, privacy: .public) chunked records.")
								saveChunks(completion: completion)
							case .failure(let error):
								completion(.failure(error))
							}
						}
					} else {
						completion(.success(()))
					}
				}
				
				func deleteChunks() {
					if !recordIDsToDeleteChunks.isEmpty {
						let records = recordIDsToDeleteChunks.removeFirst()
						self.modify(recordsToSave: [], recordIDsToDelete: records) { result in
							switch result {
							case .success:
                                self.logger.error("Deleted \(records.count, privacy: .public) chunked records.")
								deleteChunks()
							case .failure(let error):
								DispatchQueue.main.async {
									completion(.failure(error))
								}
							}
						}
					} else {
						DispatchQueue.main.async {
							completion(.success(()))
						}
					}
				}
				
				saveChunks() { result in
					switch result {
					case .success:
						deleteChunks()
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
				
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
		}

		database?.add(op)
	}

	/// Fetch all the changes in the CKZone since the last time we checked
	func fetchChangesInZone(incremental: Bool = true, completion: @escaping (Result<Void, Error>) -> Void) {

		var updatedRecords = [CKRecord]()
		var deletedRecordKeys = [CloudKitRecordKey]()
		
		func wasChanged(updated: [CKRecord], deleted: [CloudKitRecordKey], token: CKServerChangeToken?, completion: @escaping (Error?) -> Void) {
			logger.debug("Received \(updated.count, privacy: .public) updated records and \(deleted.count, privacy: .public) delete requests.")

			let op = CloudKitZoneApplyChangesOperation(delegate: delegate, updated: updated, deleted: deleted, changeToken: token)
			
			op.completionBlock = { [weak self] mainThreadOperation in
				guard let self = self, let zoneOperation = mainThreadOperation as? CloudKitZoneApplyChangesOperation else {
					completion(nil)
					return
				}
				
				if let error = zoneOperation.error {
					completion(error)
				} else {
					if let changeToken = zoneOperation.changeToken {
						self.changeToken = changeToken
					}
					completion(nil)
				}
			}
			
			DispatchQueue.main.async {
				CloudKitZoneApplyChangesOperation.mainThreadOperationQueue.add(op)
			}
			
		}
		
		let zoneConfig = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
		zoneConfig.previousServerChangeToken = changeToken
		let op = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: [zoneID: zoneConfig])
        op.fetchAllChanges = true
		op.qualityOfService = Self.qualityOfService

        op.recordZoneChangeTokensUpdatedBlock = { zoneID, token, _ in
			guard incremental else { return }
			
			wasChanged(updated: updatedRecords, deleted: deletedRecordKeys, token: token) { error in
				if let error {
					op.cancel()
					completion(.failure(error))
				}
			}
			updatedRecords = [CKRecord]()
			deletedRecordKeys = [CloudKitRecordKey]()
        }

        op.recordChangedBlock = { record in
			updatedRecords.append(record)
        }

        op.recordWithIDWasDeletedBlock = { recordID, recordType in
			let recordKey = CloudKitRecordKey(recordType: recordType, recordID: recordID)
			deletedRecordKeys.append(recordKey)
        }

        op.recordZoneFetchCompletionBlock = { zoneID ,token, _, finalChange, error in
			if case .success = CloudKitZoneResult.resolve(error) {
				wasChanged(updated: updatedRecords, deleted: deletedRecordKeys, token: token) { error in
					if let error {
						op.cancel()
						completion(.failure(error))
					}
				}
			}
			updatedRecords = [CKRecord]()
			deletedRecordKeys = [CloudKitRecordKey]()
        }

        op.fetchRecordZoneChangesCompletionBlock = { [weak self] error in
			guard let self = self else {
				completion(.failure(CloudKitZoneError.unknown))
				return
			}

			switch CloudKitZoneResult.resolve(error) {
			case .success:
				let op = CloudKitZoneApplyChangesOperation()
				
				op.completionBlock = { _ in
					completion(.success(()))
				}
				
				DispatchQueue.main.async {
					CloudKitZoneApplyChangesOperation.mainThreadOperationQueue.add(op)
				}
			case .zoneNotFound:
				self.createZoneRecord() { result in
					switch result {
					case .success:
						self.fetchChangesInZone(incremental: incremental, completion: completion)
					case .failure(let error):
						DispatchQueue.main.async {
							completion(.failure(error))
						}
					}
				}
			case .userDeletedZone:
				DispatchQueue.main.async {
					completion(.failure(CloudKitZoneError.userDeletedZone))
				}
			case .retry(let timeToWait):
                self.logger.error("\(self.zoneID.zoneName, privacy: .public) zone fetch changes retry in \(timeToWait, privacy: .public) seconds.")
				self.retryIfPossible(after: timeToWait) {
					self.fetchChangesInZone(incremental: incremental, completion: completion)
				}
			case .changeTokenExpired:
				DispatchQueue.main.async {
					self.changeToken = nil
					self.fetchChangesInZone(incremental: incremental, completion: completion)
				}
			default:
				DispatchQueue.main.async {
					completion(.failure(CloudKitError(error!)))
				}
			}
			
        }

        database?.add(op)
    }
	
}

private class CloudKitZoneApplyChangesOperation: MainThreadOperation {
	
	static let mainThreadOperationQueue = MainThreadOperationQueue()

	// MainThreadOperation
	public var isCanceled = false
	public var id: Int?
	public weak var operationDelegate: MainThreadOperationDelegate?
	public var name: String? = "CloudKitReceiveStatusOperation"
	public var completionBlock: MainThreadOperation.MainThreadOperationCompletionBlock?

	private weak var delegate: CloudKitZoneDelegate?
	private var updated: [CKRecord]
	private var deleted: [CloudKitRecordKey]
	
	private(set) var error: Error?
	private(set) weak var changeToken: CKServerChangeToken?
	
	/// Used to queue up the final success call so that it doesn't happen before we are done processing records
	init() {
		updated = []
		deleted = []
	}
	
	/// Used for regular record processing
	init(delegate: CloudKitZoneDelegate?, updated: [CKRecord], deleted: [CloudKitRecordKey], changeToken: CKServerChangeToken?) {
		self.delegate = delegate
		self.updated = updated
		self.deleted = deleted
		self.changeToken = changeToken
	}
	
	func run() {
		guard let delegate = delegate else {
			self.operationDelegate?.operationDidComplete(self)
			return
		}
		
		delegate.cloudKitWasChanged(updated: updated, deleted: deleted) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success:
				self.operationDelegate?.operationDidComplete(self)
			case .failure(let error):
				self.error = error
				self.operationDelegate?.cancelOperation(self)
			}
		}

	}
	
}
