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
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var currentMonthStartDate: Date = Date()
    
    // MARK: - Expense / Income Tab
    @Published var tabName: ExpenseType = .expense
    
    // MARK: - Filter View
    @Published var showFilterView: Bool = false
    
    
    init(){
        // MARK: - Fetching Current Month Starting Date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        
        startDate = calendar.date(from: components)!
        currentMonthStartDate = calendar.date(from: components)!
    }
    
    // MARK: - This is a Sample Data of Month May
    // MARK: - You can Custumize thid Even more with Your Data (Core Data)
    @Published var expenses: [Expense] = sample_expenses
    
    // MARK: - Fetching Current Month Date String
    func currentMonthDateString()->String{
        return currentMonthStartDate.formatted(date: .abbreviated, time: .omitted) + " - " + Date().formatted(date: .abbreviated, time: .omitted)
    }
    
    func convertExpensesToCurrency(expense: [Expense], type:ExpenseType = .all)->String{
        var value: Double = 0
        value = expense.reduce(0, { partialResult, expense in
            return partialResult + (expense.type == .all ? (expense.type == . income ? expense.amount : -expense.amount) : (expense.type == type ? expense.amount : 0))
        })
        return convertNumbertoPrice(value: value)
    }
    
    // MARK: - Converting Selected Dates To String
    func convertDatetoString()->String{
        return startDate.formatted(date: .abbreviated, time: .omitted) + " - " + endDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    // MARK: - Converting Number to Price
    func convertNumbertoPrice(value: Double)->String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter.string(from: .init(value: value)) ?? "฿0.00"
    }
    
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
