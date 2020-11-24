//
//  RecipeRow.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 20/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct RecipeRow: View {
    let recipe : Recipe

    @State private var isFocused = false

    var body: some View {
        ZStack {
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                VStack {
                    KFImage(self.recipe.image.url)
                        .resizable()
                        .placeholder({
                            Image("Placeholder")
                        })
                        .background(Color.gray)
                        .frame(width: 400, height: 235, alignment: .center)
                        .overlay(ZStack {
                            Color.black.opacity(0.1)
                            Text(self.recipe.name)
                            .foregroundColor(Color.white)
                            .bold()
                        })
                        .blur(radius: isFocused ? 5 : 0)
                        .shadow(radius: 16)
                }
                .scaleEffect(isFocused ? 1.05 : 1.0)
                .animation(.default)
            }
            .focusable(true) { self.isFocused = $0 }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
    }
}
