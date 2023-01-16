//
//  CloudUtility.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import Foundation
import CloudKit
import Combine

// MARK: - Protocal
protocol CloudKitableProtocal {
    init?(record: CKRecord)
    var record: CKRecord { get }
}

class CloudKitUtility {
    
    // MARK: - CloudKitError
    enum CloudKitError: String , LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknow
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }// MARK: - CloudKitError
   
}


// MARK: - How to Use USER PROFILE FUNCTION
// MARK: - getCloudStatus
/*func getCloudStatus() {
    CloudKitUtility.getiCloudStatus()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.error = error.localizedDescription
            }
        } receiveValue: { [weak self] success in
            self?.isSignIntoiCloud = success
        }
        .store(in: &cancellables)
}*/
// MARK: - requestPermission
/*func requestPermission() {
    CloudKitUtility.requestApplicationPermission()
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { [weak self] success in
            self?.permissionStatus = success
        }
        .store(in: &cancellables)
}*/
// MARK: - getUserNameOnCloudKit
 /*func getCurrentUserName() {
    CloudKitUtility.discoverUserIdentity()
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { [weak self] returnedName in
            self?.userName = returnedName
        }
        .store(in: &cancellables)
}*/


// MARK: - USER PROFILE FUNCTIONS
extension CloudKitUtility {
    
    static private func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().accountStatus { returnedStatus, returnedError in
            switch returnedStatus {
            case .available:
                completion(.success(true))
            case .noAccount:
                completion(.failure(CloudKitError.iCloudAccountNotFound))
            case .couldNotDetermine:
                completion(.failure(CloudKitError.iCloudAccountNotDetermined))
            case .restricted:
                completion(.failure(CloudKitError.iCloudAccountRestricted))
            default:
                completion(.failure(CloudKitError.iCloudAccountUnknow))
            }
        }
    }
    
    static func getiCloudStatus() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static private func requestApplicationPermission (completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) {returnedStatus, returnedError in
            if returnedStatus == .granted {
                completion(.success(true))
            } else {
                completion(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static private func fetchUserRecordID(completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().fetchUserRecordID { returnedID, returnedError in
            if let id = returnedID {
                completion(.success(id))
            } else if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static private func  discoverUserIdentity(id: CKRecord.ID, completion: @escaping (Result<String, Error>) -> ()) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { returnedIdentity, returndError in
            if let name = returnedIdentity?.nameComponents?.givenName {
                completion(.success(name))
            } else if let error = returndError {
                completion(.failure(error))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
            }
        }
    }
    
    static private func discoverUserIdentity(completion: @escaping (Result<String, Error>) -> ()) {
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion {
            case .success(let recordID):
                CloudKitUtility.discoverUserIdentity(id: recordID, completion: completion )
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            CloudKitUtility.discoverUserIdentity { result in
                promise(result)
            }
        }
    }
    
}



// MARK: - How to Use CRUD FUNCTION



// MARK: - CRUD FUNCTIONS
extension CloudKitUtility {
    
    static func fetch<T:CloudKitableProtocal>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> Future<[T], Error>{
        Future { promise in
            CloudKitUtility.fetch(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }
    
    static private func fetch<T:CloudKitableProtocal>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        completion: @escaping (_ items: [T]) -> ()
    ) {
        // MARK: - create Operation
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit)
        
        // MARK: - Get Item in query
        var returnedItems: [T] = []
        addRecordMatchedBlock(operation: operation) { item in
            returnedItems.append(item)
        }
        // MARK: - Quary completion
        addQuaryResultBlock(operation: operation) { finished in
            completion(returnedItems)
        }
        
        
        // MARK: - Excute operation
        add(operation: operation)
    }
    
    static private func createOperation(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> CKQueryOperation {
        let quary = CKQuery(recordType: recordType, predicate: predicate)
        quary.sortDescriptors = sortDescriptors
        let quaryOperation = CKQueryOperation(query: quary)
        if let limit = resultsLimit {
            quaryOperation.resultsLimit = limit
        }
        return quaryOperation
    }
    
    static private func addRecordMatchedBlock<T:CloudKitableProtocal>(operation: CKQueryOperation, completion: @escaping (_ item: T) -> ()) {
        operation.recordMatchedBlock = { (returnedRecordID, returnResult) in
            switch returnResult {
            case .success(let record):
                guard let item = T(record: record) else { return }
                completion(item)
            case .failure:
                break
            }
            
            
        }
        
    }
    
    static private func addQuaryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()) {
        
        operation.queryResultBlock = { returnedResult in
            DispatchQueue.main.async {
                completion(true)
            }
            
        }
        
    }
    
    static private func add(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    
    static func add<T:CloudKitableProtocal>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        // MARK: - Get Record
        let record = item.record
        
        // MARK: - Save to CloudKit
        save(record: record, completion: completion)
    }
    
    static func update<T:CloudKitableProtocal>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        add(item: item, completion: completion)
    }
        
    
    static func save(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.save(record) { returnedRecord, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    static func delete<T:CloudKitableProtocal>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.delete(item: item, completion: promise)
        }
    }
    
    static private func delete<T:CloudKitableProtocal>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        CloudKitUtility.delete(record: item.record, completion: completion)
    }
    
    static private func delete(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { returnedRecordID, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
