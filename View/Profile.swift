//
//  profile.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import SwiftUI
import Combine

struct profile: View {
    @StateObject private var vmProfile = ProfileViewModel()
    @StateObject private var vmNotify = CloudKitPushNotificationViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 16){
                VStack(alignment: .leading) {
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
                            .lineLimit(1)
                    }
                    
                    HStack{
                        Text("Permission: \(vmProfile.permissionStatus.description.uppercased())")
                        Text("NAME: \(vmProfile.userName)")
                        
                    }
                }
                
                Button("Request Permission") {
                    vmProfile.requestPermission()
                }
                
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
        Spacer()
    }
}

struct profile_Previews: PreviewProvider {
    static var previews: some View {
        profile()
    }
}
