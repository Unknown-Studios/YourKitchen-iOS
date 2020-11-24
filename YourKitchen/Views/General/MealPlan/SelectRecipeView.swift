//
//  SelectRecipeView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 30/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct SelectRecipeView: View {
    var completion: (Date, Recipe) -> Void

    var date: Date
    @State var searchText: String = ""
    @State var storedRecipes = [Recipe]()
    @State var recommended = [Recipe]()

    var viewModel = SelectRecipeViewModel()

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            // Name
            YKSearchBar(text: self.$searchText, placeholder: "Search recipe")
            List {
                if premium && self.recommended.count > 0 {
                    Section(header: Text("Recommended")) {
                        ForEach(self.recommended, id: \.self) { recipe in
                            Text(recipe.name)
                        }
                    }
                }
                Section(header: Text("Current")) {
                    ForEach(self.storedRecipes.filter { // Simple search
                        self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                    }) { recipe in
                        Button(action: {
                            self.completion(self.date, recipe)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(recipe.name)
                        }
                    }
                }
            }
        }.navigationBarTitle(Text("Select recipe"))
            .onAppear {
                self.refreshRecipes()
                if premium {
                    viewModel.getInterests { recommended in
                        self.recommended = recommended
                    }
                }
            }
    }

    func refreshRecipes() {
        YKNetworkManager.Recipes.getAll { recipes in
            // Only let the user select main dishes
            let mainRecipes = recipes.filter { $0.recipeType == .main }
            self.storedRecipes = mainRecipes
        }
    }
}
