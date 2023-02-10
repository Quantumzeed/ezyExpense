//
//  ProfileViewModel.swift
//  ezExpense
//
//  Created by Quantum on 10/2/2566 BE.
//

import SwiftUI
import Combine
// MARK: - ProfileViewModel
class ProfileViewModel: ObservableObject {
    
    @Published var permissionStatus: Bool = false
    @Published var isSignIntoiCloud: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    var cancellables = Set<AnyCancellable>()
    
    init(){
        getCloudStatus()
        requestPermission()
        getCurrentUserName()
    }
    // MARK: - getCloudStatus
    private func getCloudStatus() {
        CloudKitUtility.getiCloudStatus()
        // MARK: - withCombine
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
        // MARK: - withCombine
    }
    
    // MARK: - requestPermission
    func requestPermission() {
        CloudKitUtility.requestApplicationPermission()
        // MARK: - withCombine
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] success in
                self?.permissionStatus = success
            }
            .store(in: &cancellables)
        // MARK: - withCombine
    }
    
    // MARK: - getUserNameOnCloudKit
    func getCurrentUserName() {
        CloudKitUtility.discoverUserIdentity()
        // MARK: - withCombine
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedName in
                self?.userName = returnedName
            }
            .store(in: &cancellables)
        // MARK: - withCombine
        
    }
    
}

