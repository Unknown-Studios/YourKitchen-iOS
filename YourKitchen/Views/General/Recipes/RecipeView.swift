//
//  RecipeView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FASwiftUI
import Firebase
import QGrid
import SwiftUI
import SwiftUIRefresh

struct RecipeView: View {
    var recipeViewModel = RecipeViewModel()
    @State var followingFeed = [FeedItem]()
    @State var loading = false
    @Binding var tab: Int

    // Advertisement
    let adUnitID: String = "ca-app-pub-5947064851146376/6321474655"

    @State var showLogin = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        LoadingView(title: "Loading Recipes..", loading: self.$loading) {
            VStack {
                VStack {
                    if !self.followingFeed.isEmpty {
                        YKGrid(self.followingFeed, columns: self.columnCount, showScrollIndicators: true, onRefresh: { refreshFeed() }) { (item) in
                            self.getFeedView(item: item)
                        }
                    } else {
                        Spacer()
                        FAText(iconName: "sad-tear", size: 50)
                            .padding()
                        Text("Nothing here yet..")
                        Button(action: {
                            self.tab = 1
                        }) {
                            Text("Explore")
                        }
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
                        .padding()
                        Spacer()
                    }
                }.onAppear {
                    if self.followingFeed.count == 0 {
                        self.refreshFeed()
                    }
                }
            }
        }.onAppear(perform: {
            self.loading = false
            RefrigeratorView().refreshRefrigerator()
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "Home",
                                            AnalyticsParameterScreenClass: RecipeView.self])
        }).padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 75)
        .navigationBarTitle("Home", displayMode: .inline)
        .navigationBarItems(trailing: self.plusButton)
    }

    @ViewBuilder func getFeedView(item: FeedItem) -> some View {
        // Calculate if it's time to show an ad and it's not uitesting (Ads look ugly on screenshots)
        if recipeViewModel.shouldShowAd() && !CommandLine.arguments.contains("-uiTesting") && !premium {
            NativeAdsViewController(adUnitID: adUnitID)
                .frame(height: 300)
                .padding()
        } else {
            NavigationLink(destination: RecipeDetailView(recipe: item.recipe)) {
                FeedRow(feedItem: item)
            }.buttonStyle(PlainButtonStyle())
        }
    }

    var columnCount: Int {
        UIDevice.current.userInterfaceIdiom == .phone ? 1 : 2
    }

    var plusButton : some View {
        return NavigationLink(destination: AddRecipeView(completion: { (recipe) in
            self.followingFeed.append(FeedItem(description: nil, recipe: recipe))
        }), label: {
            Image(systemName: "plus.circle.fill")
                .imageScale(.large)
        }).padding()
    }

    func refreshFeed() {
        self.loading = true
        YKNetworkManager.FeedItems.get { feeditems in
            self.followingFeed = feeditems.sorted(by: { (f1, f2) -> Bool in
                f1.dateAdded > f2.dateAdded
            })
            self.loading = false
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(tab: .constant(2))
    }
}
