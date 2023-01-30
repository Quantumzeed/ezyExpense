//
//  NewExpense.swift
//  ezExpense
//
//  Created by Quantum on 23/1/2566 BE.
//

import SwiftUI

struct NewExpense: View {
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    
    // MARK: - Environment Value
    @Environment(\.self) var env
    var body: some View {
        VStack{
            VStack(spacing: 15){
                Text("Add Expense")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .opacity(0.5)
                
                
                // MARK: - Custom TextField
                // MARK: - For Currency Symbol
                
                
                if let symbol = expenseViewModel.convertNumbertoPrice(value: 0)
                    .first{
                    TextField("0", text: $expenseViewModel.amount)
                        .font(.system(size: 35))
                        .foregroundColor(Color("Gradient2"))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .background{
                            Text(expenseViewModel.amount == "" ? "0" : expenseViewModel.amount)
                                .font(.system(size: 35))
                                .opacity(0)
                                .overlay(alignment: .leading) {
                                    Text(String(symbol))
                                        .opacity(0.5)
                                        .offset(x: -15, y: 5)
                                }
                        }
                        .padding(.vertical,10)
                        .frame(maxWidth: .infinity)
                        .background{
                            Capsule()
                                .fill(Color(.secondarySystemFill))
                        }
                        .padding(.horizontal,20)
                        .padding(.top)
                }
                
                // MARK: - Custom Labels
                Label {
                    TextField("Remark", text: $expenseViewModel.remark)
                } icon: {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.title3)
//                        .foregroundColor(Color("Gray"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,15)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                }
                .padding(.top,25)
                
                Label {
                   // MARK: - Checkboxes
                    CustomCheckBoxes()
                } icon: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
//                        .foregroundColor(Color("Gray"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,15)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                }
                .padding(.top,5)
                
                Label {
                    DatePicker("", selection: $expenseViewModel.date,in: Date.distantPast...Date(),displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth:.infinity, alignment: .leading)
                        .padding(.leading, 10)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.title3)
//                        .foregroundColor(Color("Gray"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,15)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                }
                .padding(.top,5)
                
                Label {
                    TextField("Tag", text: $expenseViewModel.tag)
                } icon: {
                    Image(systemName: "tag")
                        .font(.title3)
//                        .foregroundColor(Color("Gray"))
                }
                .padding(.vertical,20)
                .padding(.horizontal,15)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(expenseViewModel.color != "" ? Color(expenseViewModel.color) : Color(.secondarySystemFill))
                    
                }
                .padding(.top,5)
                HStack{
                    ForEach(expenseViewModel.expenses) { item in
                        if item.tag != "" {
                            Button {
                                expenseViewModel.tag = item.tag
                                expenseViewModel.color = item.color
                            } label: {
                                Text("\(item.tag)")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color(item.color))
                                }
                            }
                        }
                        
                        
                    }
                }
              
                
            }
            .frame(maxHeight: .infinity, alignment: .center)
            
            // MARK: - Save Button
            
            Button(action: {expenseViewModel.showProgress = true;expenseViewModel.addButtonPressed(env: env)}){
                Text(expenseViewModel.showProgress ? "Saving" : "Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(colors: [
                                    Color("Gradient1"),
                                    Color("Gradient2"),
                                    Color("Gradient3")
                                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                    .overlay {
                        if expenseViewModel.showProgress {
                            ProgressView()
                            .offset(x: -50, y: -5)
                        }
                    }
            }
            .animation(.easeIn(duration: 2), value: expenseViewModel.showProgress)
            .disabled(expenseViewModel.remark == "" || expenseViewModel.type == .all || expenseViewModel.amount == "")
            .opacity(expenseViewModel.remark == "" || expenseViewModel.type == .all || expenseViewModel.amount == "" ? 0.6 : 1)

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background{
//            Color("BG")
//                .ignoresSafeArea()
//        }
        .overlay(alignment: .topTrailing) {
            // MARK: - Close Button
                 Button {
                     env.dismiss()
                 } label: {
                     Image(systemName: "xmark")
                         .font(.title2)
                         .foregroundColor(.black)
                         .opacity(0.7)
                 }

            .padding()
           
        }
    }
    
    // MARK: - Checkboxes
    @ViewBuilder
    func CustomCheckBoxes()->some View{
        HStack(spacing: 10) {
            ForEach([ExpenseType.income,ExpenseType.expense], id: \.self) { type in
                ZStack{
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(lineWidth: 2)
                        .opacity(0.25)
                        .frame(width: 20, height: 20)
                    
                    if expenseViewModel.type == type{
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(Color("Green"))
                    }
                }
                .containerShape(Rectangle())
                .onTapGesture {
                    expenseViewModel.type = type
                }
                
                Text(type.rawValue.capitalized)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .opacity(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
    }
}

struct NewExpense_Previews: PreviewProvider {
    static var previews: some View {
        NewExpense()
            .environmentObject(ExpenseViewModel())
    }
}
