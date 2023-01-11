//
//  ContentView.swift
//  ezExpense
//
//  Created by Quantum on 6/1/2566 BE.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject private var vm = ExpenseUserViewModel()

    
    var body: some View {
        ZStack{
            if vm.permissionStatus == true {
                ExpenseList()
            } else {
                profile()
            }
            
           
            VStack{
                Spacer()
                
                Text("Status :  \(vm.permissionStatus.description.uppercased())")
                    .font(.caption2)
                    .padding(.bottom, 12)
                    .foregroundColor(.gray)
            }
            .ignoresSafeArea(.all)
            
        }
        
//        Home()
//            .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
