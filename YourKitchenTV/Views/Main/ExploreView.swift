//
//  ExploreView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 19/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import QGrid
import struct Kingfisher.KFImage

struct ExploreView: View {
    
    @State var recipes = [Recipe]()
    @Binding var hideNavigationBar : Bool
    
    var body: some View {
        VStack {
            if (self.recipes.count == 0) {
            } else {
                VStack {
                    QGrid(self.recipes, columns: 3) { recipe in
                        RecipeRow(recipe: recipe)
                    }
                }
            }
        }
        .navigationBarTitle("Explore")
        .navigationBarHidden(self.hideNavigationBar)
        .onAppear {
            self.hideNavigationBar = true
            self.getRecipes()
        }
    }
    
    func getRecipes() {
        YKNetworkManager.Recipes.getAll { (recipes) in
            self.recipes = recipes
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView(hideNavigationBar: .constant(true))
    }
}
