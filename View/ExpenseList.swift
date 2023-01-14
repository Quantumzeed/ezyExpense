//
//  home.swift
//  ezExpense
//
//  Created by Quantum on 6/1/2566 BE.
//

import SwiftUI
import CloudKit
import Combine

// MARK: - Protocal
protocol CloudKitableProtocal {
    init?(record: CKRecord)
}

// MARK: - ExpenseView
struct ExpenseModel: Hashable, CloudKitableProtocal {
    let name: String
    let imageURL: URL?
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let name = record["name"] as? String else { return nil }
        self.name = name
        let imageAsset = record["image"] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        self.record = record
    }
}
// MARK: - ExpenseView


// MARK: - ExpenseViewModel
class ExpenseViewModel: ObservableObject {
     
    @Published var text: String = ""
    @Published var expense: [ExpenseModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        fetchItem()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        addItem(name: text)
    }
    
    private func addItem(name: String) {
        let newExpense =  CKRecord(recordType: "Expense")
        newExpense["name"] = name
        
        guard
            let image = UIImage(named: "ExpenseTestJPEG"),
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("ExpenseTestJPEG.jpeg"),
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        do {
            try data.write(to: url)
            let asset = CKAsset(fileURL: url)
            newExpense["image"] = asset
            saveItem(record: newExpense)
        } catch let error {
            print(error)
        }
        
//        saveItem(record: newExpense)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) { [weak self] returnedRecord, returnedError in
//            print("Record: \(returnedRecord)")
//            print("Error: \(returnedError)")
//
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.text = ""
                // MARK: - better is update array [expense]
                self?.fetchItem()
                // MARK: - better is update array [expense]
            }
        }
    }
    
    func fetchItem() {
        let predicate = NSPredicate(value: true)
        let recordType = "Expense"
        CloudKitUtility.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedItems in
                self?.expense = returnedItems
            }
            .store(in: &cancellables)
    }
    

    
    func updateItem(expense: ExpenseModel) {
        let record = expense.record
        record["name"] = "NEW NAME!!!!!"
        saveItem(record: record)
    }
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let expenses = expense[index]
        let record = expenses.record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self]  returnedRecordID, returnedError in
            self?.expense.remove(at: index)
        }
    }
    
    
}
// MARK: - ExpenseViewModel

// MARK: - ExpenseView
struct ExpenseList: View {
    
    @StateObject private var vm = ExpenseViewModel()
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
