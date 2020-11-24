//
//  ShareView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 05/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct ShareView: View {

    var recipe: Recipe
    @State var description = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Group {
            LabelledDivider(label: "Post text")
            
            MultilineTextView(placeholder: "Enter text here..", text: self.$description)
                .frame(height: 200)
            Button(action: {
                self.addFeedItem()
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .foregroundColor(Color.white)
                    .frame(width: 280.0, height: 45.0)
                    .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
            }
            Spacer()
        }.navigationBarTitle("Share - " + self.recipe.name)
    }

    func addFeedItem() {
        let feedItem = FeedItem(description: self.description, recipe: self.recipe)
        YKNetworkManager.FeedItems.add(feedItem: feedItem) { (_) in
            print("FeedItem added")
        }
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView(recipe: Recipe.none)
    }
}
