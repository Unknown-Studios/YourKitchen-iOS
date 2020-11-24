//
//  UserRecipeRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct UserRecipeRow: View {

    var recipe: Recipe
    @State private var active: Bool = false
    @State private var image: Image?

    @State var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {
        HStack {
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                (image == nil ? Image("Placeholder") : self.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width / CGFloat(columnCount),
                           height: UIScreen.main.bounds.width / CGFloat(columnCount),
                           alignment: .center)
                    .clipped()
            }.buttonStyle(PlainButtonStyle())
        }.onAppear {
            ImageHelper.getImage(url: self.recipe.image) { (img) in
                self.image = img
            }
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: OperationQueue.main) { _ in
                self.orientation = UIDevice.current.orientation
            }
        }
    }

    var columnCount: Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 2
        } else {
            return (self.orientation.isLandscape) ? 4 : 3
        }
    }
}
