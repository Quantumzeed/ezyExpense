//
//  Home.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import SwiftUI

struct Home: View {
    @StateObject var expenseViewModel: ExpenseViewModel = .init()
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 12) {
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Text("iJustine")
                            .font(.title2.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    NavigationLink {
                        FilteredDetailView()
                            .environmentObject(expenseViewModel)
                    } label: {
                        Image(systemName: "hexagon.fill")
                            .foregroundColor(.gray)
                            .overlay(content: {
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .padding(7)
                            })
                            .frame(width: 40, height: 40)
                            .background(Color.white,in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    }
                }
                ExpenseCard()
                    .environmentObject(expenseViewModel)
                TransactionsView()
            }.padding()
        }
        .background{
            Color("BG")
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Transactions
    @ViewBuilder
    func TransactionsView()->some View{
        VStack(spacing: 15){
            Text("Transactions")
                .font(.title2.bold())
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(expenseViewModel.expenses) { expense in
                // MARK: - Transaction Card View
                TransactionCardView(expense: expense)
                    .environmentObject(expenseViewModel)
            }
            
        }
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
