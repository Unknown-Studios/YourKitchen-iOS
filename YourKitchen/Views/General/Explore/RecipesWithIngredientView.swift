//
//  RecipesWithIngredientView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import QGrid
import SwiftUI

struct RecipesWithIngredientView: View {
    var ingredient: Ingredient
    @State var loading = false
    @State var recipes = [Recipe]()

    var body: some View {
        VStack {
            LoadingView(title: "Loading ingredients..", loading: self.$loading) {
                QGrid(self.recipes, columns: self.columnCount, isScrollable: true) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRow(recipe: .constant(recipe))
                    }
                }
            }
        }.navigationBarTitle(Text("Recipes with " + self.ingredient.name))
            .onAppear {
                self.getRecipes()
            }
    }

    var columnCount: Int {
        UIDevice.current.userInterfaceIdiom == .phone ? 1 : 2
    }

    func getRecipes() {
        loading = true
        YKNetworkManager.Recipes.getAll { recipes in
            self.recipes = recipes.filter { $0.ingredients.contains(self.ingredient) }
            self.loading = false
        }
    }
}

struct RecipesWithIngredientView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesWithIngredientView(ingredient: Ingredient.none, recipes: [Recipe.none, Recipe.none])
    }
}
