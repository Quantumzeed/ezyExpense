//
//  profile.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import SwiftUI
import CloudKit
// MARK: - ExpanseUserViewModel
class ExpenseUserViewModel: ObservableObject {
    
    @Published var permissionStatus: Bool = false
    @Published var isSignIntoiCloud: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    
    init(){
        getCloudStatus()
        requestPermission()
        fetchiCloudUserRecordID()
    }
    
    private func getCloudStatus() {
        CloudKitUtility.getiCloudStatus { [weak self] completion in
            DispatchQueue.main.sync {
                switch completion {
                case .success(let success):
                    self?.isSignIntoiCloud = success
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    self?.permissionStatus = true
                }
            }
        }
            
        
    }
    
    func fetchiCloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedID, returnedError in
            if let id = returnedID {
                self?.discoveriCloudUser(id: id)
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedIdentity, returnError in
            DispatchQueue.main.async {
                if let name = returnedIdentity?.nameComponents?.givenName {
                    self?.userName = name
                }
            }
        }
    }
    
    
}
// MARK: - ExpanseUserViewModel

struct profile: View {
    @StateObject private var vm = ExpenseUserViewModel()
    @StateObject private var notify = CloudKitPushNotificationViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("IS SIGNED IN: \(vm.isSignIntoiCloud.description.uppercased())")
            Text(vm.error)
            Text("Permission: \(vm.permissionStatus.description.uppercased())")
            Text("NAME: \(vm.userName)")
            VStack(spacing: 40){
                
                Button("Request notification permissions") {
                    notify.requestNotificationPermission()
                }
                
                Button("Subscribe to notification") {
                    notify.subscribeRoNotification()
                }
                
                Button("Unsubscribe to notification") {
                    notify.subscribeRoNotification()
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
