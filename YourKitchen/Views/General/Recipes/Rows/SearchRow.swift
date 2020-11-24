//
//  SearchRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

struct SearchRow: View {
    var searchResult: SearchResult

    var body: some View {
        Group {
            if let recipe = searchResult.object as? Recipe {
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack {
                        KFImage(recipe.image.url)
                            .resizable()
                            .placeholder {
                                Image("Placeholder")
                            }
                            .cancelOnDisappear(true)
                            .frame(width: 50.0, height: 50.0)
                            .clipShape(Circle())
                        HStack {
                            Text(recipe.name)
                            Spacer()
                            Text("Recipe")
                                .foregroundColor(Color.secondary)
                                .font(.system(size: 13.0))
                        }
                    }
                }
            } else if let user = searchResult.object as? YKUser {
                NavigationLink(destination: UserDetailView(user: user)) {
                    HStack {
                        KFImage(user.image.url)
                            .resizable()
                            .cancelOnDisappear(true)
                            .frame(width: 50.0, height: 50.0)
                            .clipShape(Circle())
                        HStack {
                            Text(user.name)
                            Spacer()
                            Text("User")
                                .foregroundColor(Color.secondary)
                                .font(.system(size: 13.0))
                        }
                    }
                }
            } else if let ingredient = searchResult.object as? Ingredient {
                NavigationLink(destination: RecipesWithIngredientView(ingredient: ingredient)) {
                    HStack {
                        HStack {
                            Text("Recipes with")
                            Text(ingredient.name)
                                .bold()
                            Spacer()
                            Text("Ingredient")
                                .foregroundColor(Color.secondary)
                                .font(.system(size: 13.0))
                        }
                    }
                }
            }
        }
    }
}
