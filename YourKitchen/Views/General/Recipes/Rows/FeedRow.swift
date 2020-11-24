//
//  FeedRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

struct FeedRow: View {
    var feedItem: FeedItem
    var imageHeight : CGFloat = 250.0
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ZStack {
                KFImage(feedItem.recipe.image.url)
                    .resizable()
                    .placeholder {
                        Image("Placeholder")
                    }
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: imageHeight)
                    .clipped()
                
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .bottom, endPoint: .center))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: imageHeight)
                
                VStack {
                    Spacer()
                    HStack {
                        Text(self.feedItem.recipe.name)
                            .font(.title)
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                }.padding(8)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: imageHeight)
            VStack(alignment: .leading) { //Description part of feedRow
                NavigationLink(destination: UserDetailView(user: self.feedItem.owner)) {
                    HStack {
                        VStack {
                            KFImage(self.feedItem.owner.image.url, options: [
                                .transition(.fade(0.5))
                            ])
                                .placeholder {
                                    Image("UserImage")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60.0, height: 60.0)
                                .cornerRadius(30.0)
                                .clipped()
                            Spacer()
                        }

                        VStack(alignment: .leading) {
                            Text(self.feedItem.owner == self.feedItem.recipe.author ? "Created by" : "Shared by")
                            Text(self.feedItem.owner.name)
                                .bold()
                            Spacer()
                        }.padding(8)
                    }
                    .frame(height: 80.0)
                }.buttonStyle(HighPriorityButtonStyle())
                .frame(height: 60.0)
                
                HStack {
                    Text(self.feedItem.description ?? self.feedItem.recipe.description)
                        .font(.system(size: 20.0))
                        .lineLimit(3)
                    Spacer()
                }
            }.padding(8)
            Spacer()
        }.frame(width: 325.0, height: 450.0)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10.0)
        .clipped()
        .padding(8)
    }
}
