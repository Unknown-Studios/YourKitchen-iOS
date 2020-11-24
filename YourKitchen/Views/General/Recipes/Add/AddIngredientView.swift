//
//  AddIngredientView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 29/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct AddIngredientView: View {
    @State var name: String = ""
    @State private var units = AppConstants.Measure.units
    @State var completion: (Ingredient) -> Void
    @State var selectedUnits = [String]()
    @State var ingredientType = ""
    @State var allergen = ""

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        Form {
            TextField("Name", text: self.$name)
            Picker(selection: self.$ingredientType, label: Text("Type")) {
                ForEach(IngredientType.allIndexed, id: \.self) { i in
                    Text(i.name).tag(i.name)
                }.navigationBarTitle("Type")
            }
            Picker(selection: self.$allergen, label: Text("Allergen Type")) {
                Text("").tag("")
                ForEach(Allergen.allIndexed, id: \.self) { a in
                    Text(a.name).tag(a.name)
                }.navigationBarTitle("Allergen Type")
            }
            if self.isValidIngredient() {
                Button(action: {
                    let units = self.units.map { AppConstants.Measure.getUnitSymbol(unit: $0) }
                    let type = try? IngredientType.reverseString(self.ingredientType)
                    let allergen = try? Allergen.reverseString(self.allergen)

                    if let type = type, let user = YKNetworkManager.shared.currentUser {
                        let ingredient = Ingredient(name: self.name, units: units, ownerId: user.id, type: type, allergen: allergen)
                        YKNetworkManager.Ingredients.add(ingredient, completion: self.completion)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Done")
                }
            }
        }.navigationBarTitle("Add Ingredient")
    }

    public func isValidIngredient() -> Bool {
        if name.isEmpty {
            return false
        }
        if ingredientType == "" {
            return false
        }

        return true
    }
}
