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
    
    // MARK: - Progress
    @Published var showProgress: Bool = false
    
    // MARK: - New Expense Properties
    @Published var addNewExpense: Bool = false
    @Published var amount: String = ""
    @Published var type: ExpenseType = .all
    @Published var date: Date = Date()
    @Published var color: String = ""
    @Published var remark: String = ""
    @Published var tag:String = ""
    @Published var taged:[String] = []
    
    // MARK: - This is a Sample Data of Month May
    // MARK: - You can Custumize thid Even more with Your Data (Core Data)
//    @Published var expenses: [Expense] = sample_expenses
    @Published var expenses: [Expense] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init(){
        fetchItem()
        
        // MARK: - Fetching Current Month Starting Date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        
        startDate = calendar.date(from: components)!
        currentMonthStartDate = calendar.date(from: components)!
        
        
    }
    
    
    // MARK: - Fetching Current Month Date String
    func currentMonthDateString()->String{
        return currentMonthStartDate.formatted(date: .abbreviated, time: .omitted) + " - " + Date().formatted(date: .abbreviated, time: .omitted)
    }
    
    func convertExpensesToCurrency(expense: [Expense], type:ExpenseType = .all)->String{
        var value: Double = 0
        value = expense.reduce(0, { partialResult, expense in
            return partialResult + (type == .all ? (expense.type == .income ? expense.amount : -expense.amount) : (expense.type == type ? expense.amount : 0))
        })
        return convertNumbertoPrice(value: value)
    }
    
    func convertExpensesToCurrencyWithFilter(expense: [Expense], type:ExpenseType = .all)->String{
        var value: Double = 0
        value = expense.reduce(0, { partialResult, expense in
            
            return partialResult + (type == .all ? (expense.type == .income && expense.date > startDate && expense.date < endDate ? expense.amount : -expense.amount) : (expense.type == type && expense.date > startDate && expense.date < endDate ? expense.amount : 0) )
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
        
        return formatter.string(from: .init(value: value)) ?? "???0.00"
    }
    
    // MARK: - Clearing All Data
    func clearData(){
        date = Date()
        type = .all
        remark = ""
        amount = ""
        tag = ""
    }
    
    // MARK: - Save Data
//    func saveData(env:EnvironmentValues){
//        // MARK: - Do Actions Here
//        print("Save")
//
//        // MARK: - This is For UI Demo
//        // MARK: - replace with core data Actions
//        let amountInDouble = (amount as NSString).doubleValue
//        let colors = ["Yellow","Red","Purple","Green"]
//        let expense = Expense(remark: remark, amount: amountInDouble, date: date, type: type, color: colors.randomElement() ?? "Yellow")
//        withAnimation {expenses.append(expense!)}
//        expenses = expenses.sorted(by: { first, scnd in
//            return scnd.date > first.date
//        })
//        env.dismiss()
//    }
    
    // MARK: - Add Button Pressed
    func addButtonPressed(env:EnvironmentValues) {
        guard !remark.isEmpty else { return }
        guard !amount.isEmpty else { return }
        addItem(env: env)
    }
    
    // MARK: - Add Item Expense to CloudKit
    func addItem(env:EnvironmentValues){
        let amountInDouble = (amount as NSString).doubleValue
        let colors = ["Yellow","Red","Purple","Green"]
        guard let newExpense = Expense(remark: remark, amount: amountInDouble, date: date, type: type, color: colors.randomElement() ?? "Yellow", tag: tag ) else { return }
        CloudKitUtility.add(item: newExpense) { [weak self ] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.clearData()
                self?.fetchItem()
                env.dismiss()
                self?.showProgress = false
            }
        }
    }
    
    // MARK: - Fetch Item expense From CloudKit
    func fetchItem() {
        let predicate = NSPredicate(value: true)
        let recordType = ExpenseNames.nameRecordType
        CloudKitUtility.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedItems in
                self?.expenses = returnedItems
            }
            .store(in: &cancellables)
        
    }
    
    func updateItem(expense: Expense) {
        // MARK: - Do something
    }
    
    func deleteItem(indexSet: IndexSet){
        guard let index = indexSet.first else { return }
        let expenses = expenses[index]
        
        CloudKitUtility.delete(item: expenses)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] success in
                print("Delete id \(success)")
                self?.expenses.remove(at: index)
            }
            .store(in: &cancellables)
    }
    
    
}





// MARK: - ExpenseViewModel
class ExpenseCloudViewModel: ObservableObject {
     
    @Published var text: String = ""
    @Published var expense: [ExpenseCloudModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init(){
        cloudKitFetchItem()
    }
    
    func cloudkitAddButtonPressed() {
        guard !text.isEmpty else { return }
        cloudkitAddItem(name: text)
    }
    
    private func cloudkitAddItem(name: String) {
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
                    self?.cloudKitFetchItem()
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func cloudKitFetchItem() {
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
    
    func cloudkitUpdateItem(expense: ExpenseCloudModel) {
        guard let newExpemse = expense.update(newName: "Test Update !!") else { return }
        CloudKitUtility.update(item: newExpemse) { [weak self]result in
            print("Update Complete")
            self?.cloudKitFetchItem()
        }
    }
    
    func cloudkitDeleteItem(indexSet: IndexSet) {
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
