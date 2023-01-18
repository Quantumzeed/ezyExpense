//
//  ExpenseViewModel.swift
//  ezExpense
//
//  Created by Quantum on 18/1/2566 BE.
//

import Foundation
import Combine
import SwiftUI

class ExpenseViewModel: ObservableObject{
    // MARK: - Properties
    
    @Published var expense: [Expense] = sample_expenses
}





// MARK: - ExpenseViewModel
class ExpenseCloudViewModel: ObservableObject {
     
    @Published var text: String = ""
    @Published var expense: [ExpenseCloudModel] = []
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
            guard let newExpense = ExpenseCloudModel(name: name, imageURL: url, count: 5) else { return }
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
    
    func updateItem(expense: ExpenseCloudModel) {
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