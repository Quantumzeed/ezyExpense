//
//  profile.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
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


struct profile: View {
    @StateObject private var vmProfile = ProfileViewModel()
    @StateObject private var vmNotify = CloudKitPushNotificationViewModel()
    
    var body: some View {
        VStack {
            HStack{
                Text("Cloud☁️")
                    .foregroundColor(Color.accentColor)
                if vmProfile.isSignIntoiCloud {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                }
                Text(vmProfile.error)
            }
                Text("Permission: \(vmProfile.permissionStatus.description.uppercased())")
                Text("NAME: \(vmProfile.userName)")
            
            
            VStack(spacing: 40){
                
                Button("Request notification permissions") {
                    vmNotify.requestNotificationPermission()
                }
                
                Button("Subscribe to notification") {
                    vmNotify.subscribeRoNotification()
                }
                
                Button("Unsubscribe to notification") {
                    vmNotify.subscribeRoNotification()
                }
            }
        }
        .padding()
    }
}

struct profile_Previews: PreviewProvider {
    static var previews: some View {
        profile()
    }
}
