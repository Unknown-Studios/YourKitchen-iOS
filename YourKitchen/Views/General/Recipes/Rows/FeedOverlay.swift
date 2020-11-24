//
//  FeedOverlay.swift
//  YourKitchen
//
//  Created by Markus Moltke on 05/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct FeedOverlay: View {

    var recipe: Recipe

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.2))

            VStack {
                Spacer()
                HStack {
                    Text(self.recipe.name)
                        .font(.system(size: 25.0))
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                HStack {
                    Text(self.recipe.author.name)
                        .font(.system(size: 16.0))
                        .foregroundColor(.white)
                    Spacer()
                }
            }.padding()
        }
    }
}

struct FeedOverlay_Previews: PreviewProvider {
    static var previews: some View {
        FeedOverlay(recipe: Recipe.none)
    }
}
