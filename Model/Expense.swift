//
//  Expense.swift
//  ezExpense
//
//  Created by Quantum on 18/1/2566 BE.
//

import Foundation
import CloudKit

// MARK: - recordType and Colume
struct ExpenseNames {
    // MARK: - recordType Name
    static let nameRecordType = "ExpenseTracking"
    // MARK: - feild Name
    static let remark = "remark"
    static let amount = "amount"
    static let date = "date"
    static let type = "type"
    static let color = "color"
    static let tag = "tag"
    
}

// MARK: - Expense Model and Sample Data
struct Expense: Identifiable, Hashable, CloudKitableProtocal {
    var id = UUID().uuidString
    var remark: String
    var amount: Double
    var date: Date
    var type: ExpenseType
    var color: String
    var tag: String
    let record: CKRecord
    
    init?(record: CKRecord){
        guard let remark = record[ExpenseNames.remark] as? String else { return nil }
        self.remark = remark
        let amount = record[ExpenseNames.amount] as? Double
        self.amount = amount ?? 0
        let date = record[ExpenseNames.date] as? Date
        self.date = date ?? Date()
        let type = record[ExpenseNames.type] as? String
        if type == "income" {
            self.type = ExpenseType.income
        } else {
            self.type = ExpenseType.expense
        }
        let color = record[ExpenseNames.color] as? String
        self.color = color ?? ""
        let tag = record[ExpenseNames.tag] as? String
        self.tag = tag ?? ""
        self.record = record
    }
    
    init?(remark: String, amount:Double?, date:Date?, type:ExpenseType?, color:String?, tag:String?){
        let record = CKRecord(recordType: ExpenseNames.nameRecordType)
        record[ExpenseNames.remark] = remark
        if let amount = amount {
            record[ExpenseNames.amount] = amount
        }
        if let date = date {
            record[ExpenseNames.date] = date
        }
        if let type = type {
            record[ExpenseNames.type] = (type == ExpenseType.expense ? ExpenseType.expense.rawValue : ExpenseType.income.rawValue)
        }
        if let color = color {
            record[ExpenseNames.color] = color
        }
        if let tag = tag {
            record[ExpenseNames.tag] = tag
        }
        self.init(record: record)
    }
    
    func update(newRemark: String, newAmount:Double?, newDate:Date?, newType:ExpenseType?, newColor:String?, newTag:String?) -> Expense?{
        let record = record
        //        CKRecord(recordType: ExpenseNames.nameRecordType)
        record[ExpenseNames.remark] = newRemark
        record[ExpenseNames.amount] = newAmount
        record[ExpenseNames.date] = newDate
        record[ExpenseNames.type] = (newType == ExpenseType.expense ? ExpenseType.expense.rawValue : ExpenseType.income.rawValue)
        record[ExpenseNames.color] = newColor
        record[ExpenseNames.tag] = newTag
        return Expense(record: record)
    }
    
    
    
}
enum ExpenseType: String {
    case income = "income"
    case expense = "expense"
    case all = "ALL"
}




//var sample_expenses: [Expense] = [
//    Expense(remark: "Magic Keyboard",   amount: 99, date: Date (timeIntervalSince1970: 1652987245), type: .expense, color: "Yellow", tag: "")!,
//    Expense(remark: "Food",             amount: 19, date: Date(timeIntervalSince1970: 1652814445),  type: .expense, color: "Red")!,
//    Expense(remark: "Magic Trackpad",   amount: 99, date: Date (timeIntervalSince1970: 1652382445), type: .expense, color: "Purple")!,
//    Expense(remark: "Uber Cab",         amount: 20, date: Date(timeIntervalSince1970: 1652296045),  type: .expense, color: "Green")!,
//    Expense(remark: "Amazon Purchase",  amount: 299, date:Date(timeIntervalSince1970: 1652209645) , type: .income, color: "Yellow")!,
//    Expense(remark: "Stocks",           amount: 399, date: Date (timeIntervalSince1970: 1652036845), type: .expense, color: "Purple")!,
//    Expense(remark: "In App Purchase",  amount: 5.99,date:Date(timeIntervalSince1970:1651864045),   type: .expense, color: "Red")!,
//    Expense(remark: "Movie Ticket",     amount: 99, date: Date (timeIntervalSince1970: 1651691245), type: .expense, color: "Yellow")!,
//    Expense(remark: "Apple Music",      amount: 25, date: Date (timeIntervalSince1970: 1651518445), type: .expense, color: "Green")!,
//    Expense(remark: "Snacks",           amount: 49, date: Date (timeIntervalSince1970: 1651432045), type: .expense, color: "Purple")!,
//]



// MARK: - recordType and Colume
struct CloudKitExpenseNames {
    // MARK: - recordType Name
    static let nameRecordType = "Expense"
    // MARK: - feild Name
    static let name = "name"
    static let image = "image"
    static let count = "count"
}

// MARK: - ExpenseModel
struct ExpenseCloudModel: Hashable, CloudKitableProtocal {
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
    
    func update(newName:String) -> ExpenseCloudModel? {
        let record = record
        record[CloudKitExpenseNames.name] = newName
        return ExpenseCloudModel(record: record)
    }
    
}
// MARK: - ExpenseModel


