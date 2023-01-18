//
//  home.swift
//  ezExpense
//
//  Created by Quantum on 6/1/2566 BE.
//

import SwiftUI


// MARK: - ExpenseView
struct ExpenseList: View {
    
    @StateObject private var vm = ExpenseCloudViewModel()
    @State private var searchText = ""
    
    var body: some View {
//        ScrollView{
            VStack{
                header
                textField
                addButton
                
                List{
                    ForEach(vm.expense, id: \.self) { expense in
                        HStack{
                            if let url = expense.imageURL,
                               let data = try? Data(contentsOf: url ),
                               let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text(expense.name)
                        }
                        .onTapGesture {
                                vm.updateItem(expense: expense)
                            }
                    }
                    .onDelete(perform: vm.deleteItem)
                }
//                .refreshable(action: {
//                    vm.fetchItem()
//                })
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationBarHidden(true)
//            .searchable(text: $searchText, prompt: "search")
//        }
       
    }
}
// MARK: - ExpenseView

struct home_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseList()
    }
}


extension ExpenseList {
    private var header: some View {
        Text("CloudKit CRUD ☁️☁️☁️")
            .font(.headline)
            .underline()
    }
    
    private var textField: some View {
        TextField("Add something here...", text: $vm.text)
            .frame(height: 55)
            .padding(.leading)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
    }
    
    private var addButton: some View {
        
        Button {
            vm.addButtonPressed()
        } label: {
            Text("Add")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.pink)
                .cornerRadius(10)
        }
        
    }
}
