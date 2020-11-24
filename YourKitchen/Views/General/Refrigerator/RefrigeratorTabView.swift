//
//  RefrigeratorTabView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct RefrigeratorTabView: View {
    @Binding var refrigerator: Refrigerator
    @Binding var shoppingList: ShoppingList
    @Binding var storedIngredients: [Ingredient]
    @Binding var storedRecipes: [Recipe]

    @State var oldIngredient = Ingredient.none
    @State var actionState: Int? = 0

    var updateRefrigerator: () -> Void

    var body: some View {
        List {
            NavigationLink(destination: IngredientList(
                // oldIngredient: Ingredient.none,
                            itemClicked: { (newIngredient, newRecipe)  in
                                if let newIngredient = newIngredient {
                                    self.refrigerator.ingredients.append(newIngredient)
                                    self.changeShoppingList(newIngredient: newIngredient)
                                    self.updateRefrigerator()
                                }
                            }, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes),
                           tag: 1, selection: self.$actionState) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20 * AppConstants.multiplier))
                    Text("Select new ingredient")
                        .font(.system(size: 16 * AppConstants.multiplier))
                }
            }.isDetailLink(false)
            ForEach(self.refrigerator.ingredients.indices, id: \.self) { item in
                NavigationLink(destination: IngredientList(
                    // oldIngredient: self.getIngredient(item),
                    itemClicked: { (newIngredient, newRecipe) in
                        if let newIngredient = newIngredient {
                            if let row = self.refrigerator.ingredients.firstIndex(where: { $0.id == oldIngredient.id }) {
                                self.refrigerator.ingredients[row] = newIngredient // If index found where oldIngredient where
                            } else {
                                self.refrigerator.ingredients.append(newIngredient) // If not found
                            }
                            self.changeShoppingList(newIngredient: newIngredient)
                        } else if let newRecipe = newRecipe {
                            for ing in newRecipe.ingredients {
                                if let row = self.refrigerator.ingredients.firstIndex(where: { $0.id == oldIngredient.id }) {
                                    self.refrigerator.ingredients[row] = ing // If index found where oldIngredient where
                                } else {
                                    self.refrigerator.ingredients.append(ing) // If not found
                                }
                                self.changeShoppingList(newIngredient: ing)
                            }
                        }
                        self.updateRefrigerator()
                    }, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes),
                               tag: item + 2, selection: self.$actionState) {
                    Text(self.getIngredient(item).description)
                        .font(.system(size: 16 * AppConstants.multiplier))
                }.isDetailLink(false)
            }.onDelete(perform: self.deleteIngredient)
        }.onAppear(perform: {
            self.oldIngredient = Ingredient.none
        }).onDisappear {
            if self.actionState ?? 0 > 1 {
                self.oldIngredient = self.getIngredient((self.actionState ?? 2) - 2)
            }
        }
    }

    /**
     Change the shoppinglist with the newly provided ingredients
     */
    func changeShoppingList(newIngredient: Ingredient) {
        // Ingredient in shoppinglist
        let ingredient: Ingredient = shoppingList.ingredients.filter { $0 == newIngredient }.first ?? Ingredient.none
        // newIngredient: Ingredient chosen in refrigerator
        if ingredient.amount - newIngredient.amount > 0 { // If ingredient should be updated
            shoppingList.ingredients.removeAll { (ing) -> Bool in // Remove items with same id
                ing == newIngredient
            }
            let tmpIngredient = newIngredient // Convert to var
            tmpIngredient.amount = ingredient.amount - newIngredient.amount
            shoppingList.ingredients.append(tmpIngredient) // Add item with new amount
        } else { // If ingredient should be removed
            shoppingList.ingredients.removeAll { (ing) -> Bool in // Remove items with same id
                ing == newIngredient
            }
        }
        updateShoppingList()
    }

    func deleteIngredient(at offsets: IndexSet) {
        refrigerator.ingredients.remove(atOffsets: offsets)
        updateRefrigerator()
    }

    func updateShoppingList() {
        YKNetworkManager.ShoppingLists.update(shoppingList: shoppingList)
    }

    func getIngredient(_ key: Int) -> Ingredient {
        let arr = Array(refrigerator.ingredients)
        return arr[key]
    }
}
