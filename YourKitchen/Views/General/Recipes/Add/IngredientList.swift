//
//  IngredientList.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct IngredientList: View {
    // var oldIngredient: Ingredient?
    var itemClicked: (Ingredient?, Recipe?) -> Void

    @Binding var storedIngredients: [Ingredient]
    @Binding var storedRecipes: [Recipe]
    @State var newIngredient : Ingredient?
    @State var newRecipe : Recipe?
    @State var searchText = ""
    @State var isShowingAlert = false
    @State var alertIngredientText = ""

    @State var amount = ""
    @State var amountUnit: String = ""
    @State var showAmount = false
    @State var selectedIngredient = Ingredient.none

    @State var searchResults = [SearchResult]()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if !self.showAmount {
                // Name
                YKSearchBar(text: self.$searchText.onUpdate {
                    self.search()
                }, placeholder: "Search ingredients")
                List {
                    NavigationLink(destination: AddIngredientView(completion: { ingredient in
                        self.storedIngredients.append(ingredient)
                    })) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 20))
                            Text("Add new ingredient")
                        }
                    }
                    if self.searchText != "" && self.searchResults.count > 0 {
                        ForEach(self.searchResults, id: \.self) { result in
                            if let ingredient = result.object as? Ingredient {
                                Button {
                                    self.newIngredient = ingredient
                                    self.showAmount = true
                                } label: {
                                    VStack {
                                        Text(ingredient.name)
                                    }.frame(alignment: .leading)
                                }
                            } else if let recipe = result.object as? Recipe {
                                Button(action: { //No reason to select amount if we're choosing a recipe
                                    self.presentationMode.wrappedValue.dismiss()
                                    self.itemClicked(nil, recipe)
                                }, label: {
                                    VStack {
                                        Text(recipe.name)
                                    }.frame(alignment: .leading)
                                })
                            } else {
                                EmptyView()
                            }
                        }
                    } else {
                        ForEach(self.storedIngredients, id: \.self) { ingredient in
                            Button {
                                self.newIngredient = ingredient
                                self.showAmount = true
                            } label: {
                                VStack {
                                    Text(ingredient.name)
                                }.frame(alignment: .leading)
                            }
                        }
                        ForEach(self.storedRecipes, id: \.self) { (recipe) in
                            Button(action: { //No reason to select amount if we're choosing a recipe
                                self.presentationMode.wrappedValue.dismiss()
                                self.itemClicked(nil, recipe)
                            }, label: {
                                VStack {
                                    Text(recipe.name)
                                }.frame(alignment: .leading)
                            })
                        }
                    }
                }
            } else {
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
                                    if let returnIngredient = self.newIngredient {
                                        returnIngredient.amount = amount
                                        returnIngredient.units = [self.amountUnit]
                                        self.presentationMode.wrappedValue.dismiss()
                                        self.itemClicked(returnIngredient, nil)
                                    } else if let returnRecipe = self.newRecipe {
                                        self.presentationMode.wrappedValue.dismiss()
                                        self.itemClicked(nil, returnRecipe)
                                    }
                                        
                                }
                            }) {
                                Text("Done")
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(Text("Ingredients"))
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

    func search() {
        if searchText.isEmpty {
            print("Using stored ingredients: " + storedIngredients.count.description)
            storedIngredients = storedIngredients.sorted { (i1, i2) -> Bool in
                i1.count > i2.count
            }
        } else {
            YKNetworkManager.Search.search(search_query: searchText, types: ["ingredient", "recipe"]) { results in
                print("Results gotten: " + results.count.description)
                self.searchResults = results
            }
        }
    }
}
