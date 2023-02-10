//
//  Home.swift
//  ezExpense
//
//  Created by Quantum on 10/1/2566 BE.
//

import SwiftUI

struct Home: View {
    @State private var showProfile: Bool = false
    @StateObject var expenseViewModel: ExpenseViewModel = .init()
    var body: some View {
        VStack{
            VStack{
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                withAnimation {
                                    showProfile = true
                                }
                            }
                            .sheet(isPresented: $showProfile) {
                                profile()
                                    .presentationDetents([.medium, .large])
                            }

                        Text("ออมตัง")
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
                            .background(Color(.systemBackground),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .secondary.opacity(0.4), radius: 5, x: 5, y: 5)
                    }
                }
                ExpenseCard()
                    .environmentObject(expenseViewModel)
            }
            .padding(.horizontal,12)
//            .padding(.vertical,0)
//            .padding(.bottom,0)
            TransactionsView()
        }
        
        .background{
            Color("Gradient2")
                .opacity(0.1)
                .ignoresSafeArea()
            Circle()
                .foregroundColor(Color("Gradient3"))
                .blur(radius: 75)
                .frame(width: 300, height: 300)
                .offset(x: -200, y: -100)
            
            Circle()
                .foregroundColor(Color("Gradient1"))
                .blur(radius: 75)
                .frame(width: 300, height: 300)
                .offset(x: 200, y: 250)
            
            
//
        }
        .fullScreenCover(isPresented: $expenseViewModel.addNewExpense) {
            expenseViewModel.clearData()
        } content: {
            NewExpense()
                .environmentObject(expenseViewModel)
        }
        .overlay(alignment: .bottomTrailing) {
            AddButton()
                .opacity(0.85)
        }
        
    }
    
    // MARK: - Add new Expense Button
    @ViewBuilder
    func AddButton()->some View{
        Button {
            expenseViewModel.addNewExpense.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 55, height: 55)
                .background {
                    Circle()
                        .fill(
                            .linearGradient(colors: [
                                Color("Gradient1"),
                                Color("Gradient2"),
                                Color("Gradient3")
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
        }
        .padding()
        
    }
    
    // MARK: - Transactions
    @ViewBuilder
    func TransactionsView()->some View{
        VStack(spacing: 0){
            
            List{
                Text("รายการ")
                    .font(.title2.bold())
                    .opacity(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowBackground(Color.clear)
                
                
                
                ForEach(expenseViewModel.expenses, id: \.self) { expense in
                    // MARK: - Transaction Card View
                    //                Text(expense.remark)
                    TransactionCardView(expense: expense)
                        .environmentObject(expenseViewModel)
                }
//                .onDelete(perform: expenseViewModel.deleteItem)
                .background {
                    Color.clear
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 15)
//                        .fill(Color(.secondarySystemBackground))
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                        
                        .padding(.horizontal,8)
                        .padding(4)
                )
//                .listRowSeparator(.automatic)
                .listRowSeparator(.hidden)
            }
            
            .listStyle(.plain)
            //            .scrollContentBackground(.hidden)
            
        }
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
