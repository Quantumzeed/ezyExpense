//
//  home.swift
//  ezExpense
//
//  Created by Quantum on 6/1/2566 BE.
//

import SwiftUI
import CloudKit
import Combine


struct CloudKitExpenseNames {
    // MARK: - recordType Name
    static let nameRecordType = "Expense"
    // MARK: - feild Name
    static let name = "name"
    static let image = "image"
    static let count = "count"
}

// MARK: - ExpenseView
struct ExpenseModel: Hashable, CloudKitableProtocal {
    let name: String
    let imageURL: URL?
    let count: Int
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let name = record[CloudKitExpenseNames.name] as? String else { return nil }
        self.name = name
        let imageAsset = record[CloudKitExpenseNames.image] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        let count = record[CloudKitExpenseNames.count] as? Int
        self.count = count ?? 0
        self.record = record
    }
    
    init?(name: String, imageURL: URL?, count:Int?) {
        let record = CKRecord(recordType: CloudKitExpenseNames.nameRecordType)
        record[CloudKitExpenseNames.name] = name
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record[CloudKitExpenseNames.image] = asset
        }
        if let count = count {
            record[CloudKitExpenseNames.count] = count
        }
        self.init(record: record)
    }
    
    func update(newName:String) -> ExpenseModel? {
        let record = record
        record[CloudKitExpenseNames.name] = newName
        return ExpenseModel(record: record)
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
        guard
            let image = UIImage(named: "ExpenseTestJPEG"),
            let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("ExpenseTestJPEG.jpeg"),
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        do {
            try data.write(to: url)
            guard let newExpense = ExpenseModel(name: name, imageURL: url, count: 5) else { return }
            CloudKitUtility.add(item: newExpense) { [weak self ] result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.text = ""
                    self?.fetchItem()
                }
            }
        } catch let error {
            print(error)
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
        guard let newExpemse = expense.update(newName: "Test Update !!") else { return }
        CloudKitUtility.update(item: newExpemse) { [weak self]result in
            print("Update Complete")
            self?.fetchItem()
        }
    }
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let expenses = expense[index]
        
        CloudKitUtility.delete(item: expenses)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] success in
                print("Delete id \(success)")
                self?.expense.remove(at: index)
            }
            .store(in: &cancellables)
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
