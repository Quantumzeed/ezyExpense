//
//  FilteredDetailView.swift
//  ezExpense
//
//  Created by Quantum on 19/1/2566 BE.
//

import SwiftUI

struct FilteredDetailView: View {
    @EnvironmentObject var expenseViewModel : ExpenseViewModel
    var body: some View {
        Text("Filter")
    }
}

struct FilteredDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
