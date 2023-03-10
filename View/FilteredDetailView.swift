//
//  FilteredDetailView.swift
//  ezExpense
//
//  Created by Quantum on 19/1/2566 BE.
//

import SwiftUI

struct FilteredDetailView: View {
    @EnvironmentObject var expenseViewModel : ExpenseViewModel
    @Environment(\.self) var env
    @Namespace var animation
    var body: some View {
            VStack(spacing:0) {
                VStack{
                HStack(spacing: 15) {
                    // MARK: - Back Button
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill")
                            .foregroundColor(.secondary)
//                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                            .background(Color(.systemBackground),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .secondary.opacity(0.4), radius: 5, x: 5, y: 5)
                    }

                    Text("รายการ")
                        .font(.caption)
                        .opacity(0.7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        expenseViewModel.showFilterView = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.secondary)
//                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                            .background(Color(.systemBackground),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .secondary.opacity(0.4), radius: 5, x: 5, y: 5)
                    }

                }
                
                // MARK: - ExpenseCard View For Currently Selected Date
//                ExpenseCard(isFilter: true)
//                    .environmentObject(expenseViewModel)
                
                CustomSegmentedControl()
                    .padding(.top)
                    
                
                // MARK: - Currently Filtered Date with Amount
                VStack(spacing:15){
                    Text(expenseViewModel.convertDatetoString())
                        .opacity(0.7)
                    
                    Text(expenseViewModel.convertExpensesToCurrencyWithFilter(expense: expenseViewModel.expenses, type: expenseViewModel.tabName))
                        .font(.title.bold())
                        .foregroundColor(Color("Gradient2"))
                        .opacity(0.9)
                        .animation(.none, value: expenseViewModel.tabName)
                }
                .padding()
                
                .frame(maxWidth: .infinity)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(LinearGradient(colors:
                                                [Color("Gradient1"),
                                                 Color("Gradient2"),
                                                 Color("Gradient3"),
                                                ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.75)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        })
//                        .fill(Color(.secondarySystemBackground))
                        .opacity(0.8)                }
                .padding(.vertical,20)
                
                    
                }
                .padding(.horizontal)
                .shadow(color: .secondary.opacity(0.25), radius: 2, x: 2, y: 2)
                
                
                List {
                    ForEach(expenseViewModel.expenses.filter{ return $0.type == expenseViewModel.tabName && $0.date > expenseViewModel.startDate && $0.date < expenseViewModel.endDate }) { expense in
                        TransactionCardView(expense: expense)
                            .environmentObject(expenseViewModel)
                        
                    }
                    .onDelete(perform: expenseViewModel.deleteItem)
                    
                    .background {
                        Color.clear
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.secondarySystemBackground))
                        //                        .fill(Color(.secondarySystemFill))
                            .opacity(0.8)
                        
                            .padding(.horizontal,8)
                                                                  .padding(4)
                    )
                    //                .listRowSeparator(.automatic)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                
                
                
                
            }
            .padding(0)
            .navigationBarHidden(true)
//        .background{
//            Color("BG")
//                .ignoresSafeArea()
//        }
        .overlay {
            FilterView()
        }
    }
    
    // MARK: - Filter View
    @ViewBuilder
    func FilterView()->some View{
        ZStack{
            Color.black
                .opacity(expenseViewModel.showFilterView ? 0.25:0)
            
            // MARK: - based On the Date Filter Expenses Array
            if expenseViewModel.showFilterView{
                VStack(alignment: .leading, spacing: 10) {
                    Text("Start Date")
                        .font(.caption)
                        .opacity(0.7)
                    DatePicker("", selection: $expenseViewModel.startDate,in: Date.distantPast...Date(), displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    
                    Text("End Date")
                        .font(.caption)
                        .opacity(0.7)
                        .padding(.top,10)
                    DatePicker("", selection: $expenseViewModel.endDate,in: Date.distantPast...Date(), displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                }
                .padding(20)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                    
                        .opacity(0.8)
                    
                }
                // MARK: - close Button
                .overlay(alignment: .topTrailing) {
                    Button {
                        expenseViewModel.showFilterView = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
//                            .foregroundColor(.black)
                            .padding(5)
                    }

                }
                .padding()
            }
        }
        .animation(.easeInOut, value: expenseViewModel.showFilterView)
    }
    
    // MARK: - Custom Segmented Control
    @ViewBuilder
    func CustomSegmentedControl()->some View{
        HStack(spacing:0){
            ForEach([ExpenseType.income,ExpenseType.expense],id:\.rawValue) { tab in
                Text(tab == .income ? "รายรับ" : "รายจ่าย")
                    .fontWeight(.semibold)
//                    .foregroundColor(expenseViewModel.tabName == tab ? .white : .black)
                    .opacity(expenseViewModel.tabName == tab ? 1 : 0.7)
                    .padding(.vertical,12)
                    .frame(maxWidth: .infinity)
                    .background{
                        // MARK: - With Matched Geometry Effet
                        if expenseViewModel.tabName == tab {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    LinearGradient(colors:
                                                    [Color("Gradient1"),
                                                     Color("Gradient2"),
                                                     Color("Gradient3"),
                                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                    .containerShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            expenseViewModel.tabName = tab
                        }
                    }
            }
        }
        .padding(5)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(LinearGradient(colors:
                                        [Color("Gradient1"),
                                         Color("Gradient2"),
                                         Color("Gradient3"),
                                        ], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.75)
                .background(content: {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                })
                .opacity(0.8)
        }
    }
}

struct FilteredDetailView_Previews: PreviewProvider {
    static var previews: some View {
//        ContentView()
        FilteredDetailView()
            .environmentObject(ExpenseViewModel())
    }
}
