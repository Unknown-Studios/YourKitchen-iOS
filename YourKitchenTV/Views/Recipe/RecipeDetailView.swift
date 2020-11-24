//
//  RecipeDetailView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 19/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe
    @State var selectedIngredient: Ingredient?
    @State var selectedStep: String?

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ScrollView {
                KFImage(self.recipe.image.url, options: [
                    .transition(.fade(0.5))
                ])
                    .placeholder {
                        Image("Placeholder")
                    }.resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(125)
                Text(recipe.name)
                    .font(.title)
                    .foregroundColor(Color.white)
                Text(recipe.author.name)
                    .font(.headline)
                    .foregroundColor(Color.gray)
                HStack {
                    // Like buttons
                    EmptyView()
                }
                HStack {
                    VStack {
                        Text("Ingredients")
                            .foregroundColor(Color.white)
                            .font(.subheadline)
                        List {
                            ForEach(self.recipe.ingredients) { ingredient in
                                self.getIngredientRow(ingredient)
                                    .frame(width: 300.0, height: 60.0)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(self.colorScheme == .light ? Color.white.opacity(self.getOpacity(ingredient)) : Color.black.opacity(self.getOpacity(ingredient))))
                            }
                        }.frame(height: 600)
                    }.frame(width: 300)
                    VStack {
                        List {
                            ForEachWithIndex(self.recipe.steps, id: \.self) { idx, step in
                                VStack(alignment: .leading) {
                                    self.getStepRow(idx, step)
                                }
                                .background(RoundedRectangle(cornerRadius: 10).fill(self.colorScheme == .light ? Color.white.opacity(self.getOpacity(step)) : Color.black.opacity(self.getOpacity(step))))
                            }
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity)
                    Spacer()
                }
            }
        }.background(ZStack {
            KFImage(self.recipe.image.url)
                .placeholder {
                    Image("Placeholder")
                }.blur(radius: 20)
            Rectangle().fill(Color.black.opacity(0.2))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        })
    }

    func getOpacity(_ ingredient: Ingredient) -> Double {
        if ingredient == selectedIngredient {
            return 0.6
        } else {
            return 0.3
        }
    }

    func getOpacity(_ step: String) -> Double {
        if step == selectedStep {
            return 0.6
        } else {
            return 0.3
        }
    }

    func getStepRow(_ idx: Int, _ step: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Step " + (idx + 1).description + ".")
                    .foregroundColor(Color.white)
                Spacer()
            }
            HStack {
                Text(step)
                    .foregroundColor(Color.white)
            }
        }.frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .focusable(true) { focus in
                if focus {
                    self.selectedStep = step
                } else {
                    self.selectedStep = nil
                }
            }
    }

    func getIngredientRow(_ ingredient: Ingredient) -> some View {
        let unit = ingredient.unit
        return Text(ingredient.amount.description + unit + " x " + ingredient.name)
            .foregroundColor(Color.white)
            .focusable(true) { focus in
                if focus {
                    self.selectedIngredient = ingredient
                } else {
                    self.selectedIngredient = nil
                }
            }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipe: Recipe.none)
    }
}
