//
//  ExploreView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 18/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Firebase
import QGrid
import SwiftUI

struct ExploreView: View {
    @State var users = [YKUser]()
    @State var ingredients = [Ingredient]()
    @State var searchText = ""
    @State var loading = false

    @ObservedObject var exploreViewModel = ExploreViewModel()

    @State var lastDocument: DocumentSnapshot?

    @State var searchResults = [SearchResult]()

    // Advertisement
    let adUnitID: String = "ca-app-pub-5947064851146376/6321474655"

    @State var selectedCategory = 0

    @State var prepUnder30 = false
    @State var veganType = 0
    @State var ingredientsCount = 100.0

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    YKSearchBar(text: self.$searchText.onChange { value in
                        if value == "" {
                            self.loading = false
                        } else {
                            self.getSearch()
                        }
                    }, placeholder: "Search")
                    SelectCategoryView(selectedCategory: self.$selectedCategory, recipes: .constant(self.exploreViewModel.items))
                }
                if self.searchText != "" {
                    if self.loading {
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                        Spacer()
                    } else {
                        List {
                            ForEach(self.searchResults, id: \.self) { result in
                                SearchRow(searchResult: result)
                            }
                        }.resignKeyboardOnDragGesture()
                    }
                } else if !self.exploreViewModel.items.isEmpty {
                    YKGrid(self.filteredRecipes, columns: self.columnCount, isScrollable: true,
                           endReached: {
                            self.exploreViewModel.loadMoreContent()
                           }, onRefresh: {
                            print("Refresh called")
                            self.exploreViewModel.loadMoreContent(reset: true)
                           }) { (recipe) in
                        self.getRecipeView(recipe: recipe)
                    }.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 75)
                } else {
                    EmptyList()
                }
            }
            .navigationBarTitle("Explore", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: ExploreFilterView(recipes: .constant(self.exploreViewModel.items), selectedVeganType: self.$veganType, prepUnder30: self.$prepUnder30, ingredientsCount: self.$ingredientsCount), label: {
                HStack {
                    Spacer()
                    Text(self.filterCount)
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .imageScale(.large)
                }
                .padding()
            }))
        }.navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.refreshFeed()
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "Explore",
                                            AnalyticsParameterScreenClass: ExploreView.self])
        }
    }

    /**
     Used to count the number of filters that has been changed
     */
    var filterCount: String {
        var count = 0
        if ingredientsCount != 100.0 {
            count += 1
        }
        if prepUnder30 {
            count += 1
        }
        if veganType != 0 {
            count += 1
        }
        if count == 0 {
            return ""
        } else {
            return "(" + count.description + ")"
        }
    }

    var filteredRecipes: [Recipe] {
        // Cuisine
        var tmpRecipes = exploreViewModel.items.filter { (recipe) -> Bool in
            if self.selectedCategory == 0 {
                return true
            } else {
                let type = Cuisine.allCases[self.selectedCategory - 1]
                return recipe.type.caseName == type.caseName
            }
        }
        // Vegan
        let veganExcludes: [String] = ["meat", "seafood", "dairy"]
        let vegetarianExcludes: [String] = ["meat", "seafood"]
        tmpRecipes = tmpRecipes.filter { (recipe) -> Bool in
            if self.veganType == 0 {
                return true
            } else if self.veganType == 1 { // Vegetarian
                for ing in recipe.ingredients {
                    if vegetarianExcludes.contains(ing.type.caseName) {
                        return false
                    }
                }
                return true
            } else { // Vegan
                for ing in recipe.ingredients {
                    if veganExcludes.contains(ing.type.caseName) {
                        return false
                    }
                }
                return true
            }
        }
        // Under 30 min prep time
        if self.prepUnder30 {
            tmpRecipes = tmpRecipes.filter { (recipe) -> Bool in
                if recipe.preparationTime.isUnder(Time(hour: 0, minute: 30)) {
                    return true
                }
                return false
            }
        }
        // Ingredient count
        tmpRecipes = tmpRecipes.filter { (recipe) -> Bool in
            let noExtras: [String] = ["other", "oils", "spices"]
            let noSpices = recipe.ingredients.filter { (ing) -> Bool in
                noExtras.contains(ing.type.caseName)
            }
            if noSpices.count <= Int(self.ingredientsCount) {
                return true
            }
            return false
        }
        return tmpRecipes
    }

    var columnCount: Int {
        UIDevice.current.userInterfaceIdiom == .phone ? 1 : 2
    }

    @ViewBuilder func getRecipeView(recipe: Recipe) -> some View {
        if let ad = exploreViewModel.adArray[recipe], ad && !CommandLine.arguments.contains("-uiTesting") && !premium {
            NativeAdsViewController(adUnitID: adUnitID)
                .frame(height: 300)
                .padding()
        } else {
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                RecipeRow(recipe: .constant(recipe))
            }.buttonStyle(PlainButtonStyle())
        }
    }
    
    func refreshFeed() {
        self.exploreViewModel.loadMoreContent(reset: true)
    }

    func getSearch() {
        loading = true
        YKNetworkManager.Search.search(search_query: searchText) { results in
            self.loading = false
            self.searchResults = results
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
