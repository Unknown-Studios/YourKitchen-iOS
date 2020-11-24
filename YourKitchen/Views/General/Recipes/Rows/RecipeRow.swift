//
//  RecipeRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

struct RecipeRow: View {
    @Binding var recipe: Recipe

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            KFImage(recipe.image.url)
                .placeholder {
                    Image("Placeholder")
                        .resizable()
                }
                .resizable()
                .cancelOnDisappear(true)
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 400.0)
                .clipped()
                .cornerRadius(15.0)

            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.35), Color.clear]),
                           startPoint: .topLeading,
                           endPoint: .center)
                .cornerRadius(15)

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Image(systemName: "star")
                        .font(.system(size: 20.0))
                        .foregroundColor(.white)
                    Text(self.recipe.rating.description)
                        .font(.system(size: 20.0))
                        .foregroundColor(.white)
                    Spacer()
                }.padding()
                Spacer()
            }
            Spacer()
            VStack {
                Spacer()
                ZStack {
                    VisualEffectView(style: colorScheme == .light ? .light : .dark)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 100)
                        .cornerRadius(15.0, corners: [.bottomLeft, .bottomRight])

                    HStack {
                        VStack(alignment: .leading) {
                            VStack {
                                HStack {
                                    Text(self.recipe.name)
                                        .font(.system(size: 25.0))
                                        .bold()
                                    Spacer()
                                }
                                HStack {
                                    Text(NSLocalizedString("By ", comment: "") + self.recipe.author.name)
                                        .font(.system(size: 17.0))
                                    Spacer()
                                }
                            }.padding()
                            Spacer()
                        }.frame(height: 100)
                        Spacer()
                    }
                }
            }
        }.frame(height: 400.0)
            .background(RoundedRectangle(cornerRadius: 15.0)
                .fill((colorScheme == .light) ? Color.white : Color(.systemGray6)))
            .clipped()
            .padding(20)
    }
}

struct RecipeRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                RecipeRow(recipe: .constant(Recipe(name: "Test recipe", description: "Something something", type: .american, recipeType: .main, preparationTime: Time(hour: 1, minute: 30), image: "", ingredients: [], steps: [], author: YKUser(name: "Markus Moltke", email: "makakwastaken@gmail.com", image: "", following: []))))
            }.background(Color.black)
            VStack {
                RecipeRow(recipe: .constant(Recipe(name: "Test recipe", description: "Something something", type: .american, recipeType: .main, preparationTime: Time(hour: 1, minute: 30), image: "", ingredients: [], steps: [], author: YKUser(name: "Markus Moltke", email: "makakwastaken@gmail.com", image: "", following: []))))
            }.background(Color.black)
        } //So contrast is visible
    }
}
