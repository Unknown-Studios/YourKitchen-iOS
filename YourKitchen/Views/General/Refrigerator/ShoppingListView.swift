//
//  ShoppingListView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct ShoppingListView: View {
    @Binding var refrigerator: Refrigerator
    @Binding var shoppingList: ShoppingList
    @Binding var storedIngredients: [Ingredient]
    @Binding var storedRecipes: [Recipe]
    @State var selectShopping = [Ingredient: Bool]()

    var updateRefrigerator: () -> Void

    @State var oldIngredient = Ingredient.none
    @State private var actionState: Int? = 0

    var body: some View {
        List {
            NavigationLink(destination: IngredientList(
                itemClicked: { (newIngredient, newRecipe) in
                    if let newIngredient = newIngredient {
                        self.shoppingList.ingredients.append(newIngredient)
                        self.selectShopping[newIngredient] = false
                    } else if let newRecipe = newRecipe {
                        for ing in newRecipe.ingredients {
                            self.shoppingList.ingredients.append(ing)
                            self.selectShopping[ing] = false
                        }
                    }
                    self.updateShoppingList()
                }, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes),
                           tag: 1, selection: $actionState) {
                Text("Select new item")
                    .font(.system(size: 16 * AppConstants.multiplier))
            }.isDetailLink(false)
            ForEachWithIndex(self.shoppingList.ingredients) { index, item in
                HStack {
                    Button(action: {
                        self.selectShopping[item] = !(self.selectShopping[item] ?? false)
                    }) {
                        Image(systemName: self.selectShopping[item] ?? false ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(self.selectShopping[item] ?? false ? .green : .primary)
                            .imageScale(.large)
                    }.padding(.horizontal)
                        .buttonStyle(HighPriorityButtonStyle())
                    NavigationLink(destination: IngredientList(
                        itemClicked: { (newIngredient, newRecipe) in
                            if let newIngredient = newIngredient {
                                if let row = self.shoppingList.ingredients.firstIndex(where: { $0 == oldIngredient }) {
                                    self.shoppingList.ingredients[row] = newIngredient // If index found where oldIngredient where
                                } else {
                                    self.shoppingList.ingredients.append(newIngredient) // If not found
                                }
                                for (k, _) in self.selectShopping where k == oldIngredient {
                                    self.selectShopping[k] = nil
                                }
                                self.selectShopping[newIngredient] = false
                            } else if let newRecipe = newRecipe {
                                for ing in newRecipe.ingredients {
                                    if let row = self.shoppingList.ingredients.firstIndex(where: { $0 == oldIngredient }) {
                                        self.shoppingList.ingredients[row] = ing // If index found where oldIngredient where
                                    } else {
                                        self.shoppingList.ingredients.append(ing) // If not found
                                    }
                                    for (k, _) in self.selectShopping where k == oldIngredient {
                                        self.selectShopping[k] = nil
                                    }
                                    self.selectShopping[ing] = false
                                }
                            }
                            self.updateShoppingList()
                        }, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes),
                                   tag: 2 + index, selection: $actionState) {
                        Text(item.description)
                            .font(.system(size: 16 * AppConstants.multiplier))
                    }.isDetailLink(false)
                }
            }
        }.onDisappear {
            print("Disappear: " + (self.actionState?.description ?? ""))
            // For all items from the shopping list that are selected
            for (k, v) in self.selectShopping where v { //Loop through all selected options
                self.refrigerator.ingredients.append(k)
                self.shoppingList.ingredients.removeAll(where: { $0 == k })
                self.selectShopping[k] = nil
            }
            self.updateShoppingList()
            self.updateRefrigerator()
        }
    }

    func updateShoppingList() {
        YKNetworkManager.ShoppingLists.update(shoppingList: shoppingList)
    }

    func getIngredient(_ key: Int) -> Ingredient {
        let arr = Array(refrigerator.ingredients)
        return arr[key]
    }
}
