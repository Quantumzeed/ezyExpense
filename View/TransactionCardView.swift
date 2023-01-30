//
//  TransactionCardView.swift
//  ezExpense
//
//  Created by Quantum on 19/1/2566 BE.
//

import SwiftUI

struct TransactionCardView: View {
    var expense: Expense
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    var body: some View {
        HStack(spacing:12) {
            
            
            Text(expense.remark)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: 0, y: 0)
            
            VStack(alignment: .trailing, spacing: 7) {
                // MARK: - Display Price
                let price = expenseViewModel.convertNumbertoPrice(value: expense.type == .expense ? -expense.amount : expense.amount)
                
                Text(price)
                    .font(.callout)
                    .opacity(0.7)
                    .foregroundColor(expense.type == .expense ? Color("Red") : Color("Green"))
                Text(expense.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .opacity(0.5)
            }
        }
        .overlay(alignment: .topLeading, content: {
            // MARK: - first letter Avatar
            if let first = expense.tag{
                Text(String(first))
                    .padding(2)
                    .padding(.horizontal,8)
                    .font(.headline)
                    .foregroundColor(.white)
                //                    .frame(width: 50, height: 50)
                    .background {
                        if let _ = expense.tag.first{
                            Capsule()
                                .fill(
                                    .linearGradient(colors: [
                                    Color(expense.color),
                                    Color(expense.color).opacity(0.5)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                    .offset(x: 0, y: -15)
            }
        })
        .padding(4)
        .background{
            RoundedRectangle(cornerRadius: 15)
                .fill(.clear)
        }
    }
}

struct TransactionCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
