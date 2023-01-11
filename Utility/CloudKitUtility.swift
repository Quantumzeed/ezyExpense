//
//  CloudUtility.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import Foundation
import CloudKit
import Combine

class CloudKitUtility {
    
    static func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
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
    }// MARK: - getiCloudStatus
    
    enum CloudKitError: String , LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknow
    }// MARK: - CloudKitError
   
}// MARK: - CloudKitUtility
