//
//  CloudKitPushNotification.swift
//  ezExpense
//
//  Created by Quantum on 12/1/2566 BE.
//

import SwiftUI
import CloudKit

// MARK: - PushNotificationViewModel
class CloudKitPushNotificationViewModel: ObservableObject {
    
    func requestNotificationPermission() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print(error)
            } else if success {
                print("Notification permissions success!")
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permissions failure.")
            }
        }
        
    }
    
    func subscribeRoNotification() {
        
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: "Expense", predicate: predicate, subscriptionID: "expense_added_to_database", options: .firesOnRecordCreation)
        
        let notification = CKSubscription.NotificationInfo()
        notification.title = "There's a new expense"
        notification.alertBody = "Open the app to check your expense"
        notification.soundName = "default"
        
        subscription.notificationInfo = notification
        
        CKContainer.default().publicCloudDatabase.save(subscription) { returnedSubscription, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("Successfully subscribed to notification!")
            }
            
        }
    }
    
    func unsubscribeRoNotification() {
        
//        CKContainer.default().publicCloudDatabase.fetchAllSubscriptions(completionHandler: T##([CKSubscription]?, Error?) -> Void)
        
        CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: "expense_added_to_database") { returnedID, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("Successfully unsubscribed!")
            }
        }
    }
}
// MARK: - PushNotificationViewModel

// MARK: - PushNotificationView
struct CloudKitPushNotification: View {
    
    @StateObject private var vm = CloudKitPushNotificationViewModel()
    
    var body: some View {
        VStack(spacing: 40){
            
            Button("Request notification permissions") {
                vm.requestNotificationPermission()
            }
            
            Button("Subscribe to notification") {
                vm.subscribeRoNotification()
            }
            
            Button("Unsubscribe to notification") {
                vm.subscribeRoNotification()
            }
        }
    }
}
// MARK: - PushNotificationView

struct CloudKitPushNotification_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitPushNotification()
    }
}


