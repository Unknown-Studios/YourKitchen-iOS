//
//  MealplanRow.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 20/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

/**
 Adaptation of the iOS MealplanRow
 */
struct MealplanRow: View {
    var date: Date
    var recipe: Recipe

    var body: some View {
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
                    Text(recipe.id != "none" ? recipe.name : "Select dish")
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
            Text(date.dateString)
                .font(.subheadline).bold()
                .foregroundColor(Color.white)
                .padding(3.0)
                .padding(.horizontal, 6.0)
                .background(RoundedRectangle(cornerRadius: 12.0)
                    .fill(Color.green))
            if recipe.id != "none" {
                Text(recipe.rating.description)
                    .font(.headline)
                    .foregroundColor(.yellow)
                Image(systemName: "star.fill")
                    .resizable()
                    .padding(0.0)
                    .foregroundColor(.yellow)
                    .frame(width: 40.0, height: 40.0)
            }
            Spacer()
        }
    }
}

struct MealplanRow_Previews: PreviewProvider {
    static var previews: some View {
        MealplanRow(date: Date(), recipe: Recipe.none)
    }
}
