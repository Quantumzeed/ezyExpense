//
//  ContentView.swift
//  ezExpense
//
//  Created by Quantum on 6/1/2566 BE.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject private var vmProfile = ProfileViewModel()

    
    var body: some View {
        ZStack{
            if vmProfile.permissionStatus == true {
                NavigationStack {
                    Home()
                        .navigationBarHidden(true)
                }
            } else {
                profile()
            }


            VStack{
                Spacer()

                Text("Status :  \(vmProfile.permissionStatus.description.uppercased())")
                    .font(.caption2)
                    .padding(.bottom, 12)
                    .foregroundColor(.gray)
            }
            .ignoresSafeArea(.all)

        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
