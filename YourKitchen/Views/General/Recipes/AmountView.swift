//
//  AmountView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 28/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct AmountView: View {
    // var oldIngredient: Ingredient?
    @State var newIngredient: Ingredient
    @State var amount = ""
    @State var amountUnit: String = ""
    var itemClicked: (Ingredient) -> Void
    @Binding var pushed: Int?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section {
                TextField("Amount", text: self.$amount)
                    .keyboardType(.decimalPad)
                Picker(selection: self.$amountUnit, label: Text("Unit")) {
                    ForEach(AppConstants.Measure.units.map { (unit) -> String in
                        if let unit = unit {
                            return unit.symbol
                        } else {
                            return ""
                        }
                    }, id: \.self) {
                        Text($0).tag($0)
                    }.navigationBarTitle(Text("Units"))
                }.navigationBarTitle(Text("Amount"))
            }
            Section {
                if self.isValidIngredient(false) {
                    Button(action: {
                        if self.isValidIngredient(true) {
                            let amount = Double(self.amount.replacingOccurrences(of: ",", with: "."))!
                            let returnIngredient = self.newIngredient
                            returnIngredient.amount = amount
                            returnIngredient.units = [self.amountUnit]
                            self.pushed = 0
                            self.itemClicked(returnIngredient)
                        }
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }

    func isValidIngredient(_ update: Bool) -> Bool {
        if self.amount.isEmpty {
            return false
        }
        guard var amount = Double(self.amount.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        if amount < 1 {
            amount = 1
        }
        if update {
            self.amount = amount.description
        }
        return true
    }
}
