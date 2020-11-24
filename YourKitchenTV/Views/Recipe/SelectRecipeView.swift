//
//  SelectRecipeView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 20/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

struct SelectRecipeView: View {
    var completion: (Date, Recipe) -> Void
    var date: Date

    @State var recipes = [Recipe]()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Select Recipe")
                .font(.largeTitle)
            if !self.recipes.isEmpty {
                List {
                    ForEach(self.recipes) { recipe in
                        Button(action: {
                            self.completion(self.date, recipe)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Spacer()
                                KFImage(recipe.image.url)
                                    .resizable()
                                    .placeholder {
                                        Image("Placeholder")
                                    }
                                    .frame(width: 120.0, height: 120.0)
                                    .clipShape(Circle())
                                VStack {
                                    HStack {
                                        Text(recipe.name)
                                            .font(.headline).bold()
                                        Spacer()
                                    }
                                    HStack {
                                        Text(recipe.author.name)
                                            .font(.subheadline)
                                            .foregroundColor(Color.secondary)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                Spacer()
                                Text(recipe.rating.description)
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .padding(0.0)
                                    .foregroundColor(.yellow)
                                    .frame(width: 40.0, height: 40.0)
                                Spacer()
                            }
                        }.buttonStyle(PlainButtonStyle())
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    }
                }
            } else {
                Text("Loading recipes..")
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }
        }.onAppear {
            self.refreshRecipes()
        }
    }

    func refreshRecipes() {
        YKNetworkManager.Recipes.getAll { recipes in
            print(recipes.count)
            self.recipes = recipes
        }
    }
}

struct SelectRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectRecipeView(completion: { d, _ in
            print(d)
        }, date: Date())
    }
}
