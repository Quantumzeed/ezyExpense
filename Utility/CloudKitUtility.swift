//
//  CloudUtility.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import Foundation
import CloudKit
import Combine


// MARK: - How to Use USER FUNCTION
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
    
}
