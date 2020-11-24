//
//  RecipeTypeRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 17/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import protocol Kingfisher.ImageProcessor
import struct Kingfisher.BlurImageProcessor
import struct Kingfisher.KFImage

struct RecipeTypeRow: View {
    
    var tag : Int
    @Binding var selection : Int
    @State var recipe = Recipe.none
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            KFImage(self.recipe.image.url, options: [
                .transition(.fade(0.2)),
                .processor (
                    BlurImageProcessor(blurRadius: 1.0)
                )
            ])
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150.0, height: 110.0)
            .clipped()
            .cornerRadius(15)
            
            RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.1))
            
            VStack(alignment: .leading) {
                Text(self.recipe.type.prettyName)
                    .foregroundColor(Color.white)
                    .bold()
            }.padding(10)
        }
        .frame(width: 150.0, height: 110.0)
        .padding()
    }
}

struct RecipeTypeRow_Previews: PreviewProvider {
    static var previews: some View {
        RecipeTypeRow(tag: 1, selection: .constant(1))
    }
}
