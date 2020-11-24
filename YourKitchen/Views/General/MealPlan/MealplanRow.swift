//
//  MealplanRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 30/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Combine
import struct Kingfisher.KFImage
import SwiftUI

struct MealplanRow: View {
    @Binding var meal: Meal

    init(meal: Binding<Meal>) {
        self._meal = meal
    }

    var body: some View {
        HStack {
            KFImage(self.meal.recipe.image.url)
                .placeholder {
                    Image("Placeholder")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80.0, height: 80.0)
                .clipShape(Circle())
            VStack {
                HStack {
                    Text(self.meal.date.dateString)
                        .font(.system(size: 16.0)).bold()
                        .foregroundColor(Color.white)
                        .padding(3.0)
                        .padding(.horizontal, 6.0)
                        .background(RoundedRectangle(cornerRadius: 12.0)
                            .fill(Color.green))
                    Spacer()
                }
                HStack {
                    Text(self.meal.recipe.id != "none" ? self.meal.recipe.name : "Select dish")
                        .font(.system(size: 20.0)).bold()
                    Spacer()
                }
                if self.meal.recipe.id != "none" {
                    HStack {
                        Text(self.meal.recipe.author.name + " -")
                            .font(.system(size: 15.0))
                            .foregroundColor(Color.secondary)
                        Text(self.meal.recipe.rating.description)
                            .font(.system(size: 15.0))
                            .foregroundColor(.yellow)
                        Image(systemName: "star.fill")
                            .resizable()
                            .padding(0.0)
                            .foregroundColor(.yellow)
                            .frame(width: 10.0, height: 10.0)
                        Spacer()
                    }.offset(y: -15.0)
                        .padding(.bottom, -15.0)
                }
                Spacer()
            }
        }.padding(.vertical, 4)
    }
}
