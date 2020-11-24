//
//  ExploreViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 11/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Combine
import FirebaseFirestore
import Foundation

class ExploreViewModel: ObservableObject {
    @Published var adArray = [Recipe: Bool]()
    @Published var items = [Recipe]()
    private var isLoadingPage = false
    private var lastDocument: DocumentSnapshot?
    private var canLoadMorePages = true
    private var recipeViewModel = RecipeViewModel()

    init() {
        loadMoreContent()
    }

    func loadMoreContent(reset : Bool = false) {
        guard !isLoadingPage, canLoadMorePages else {
            return
        }

        isLoadingPage = true
        
        if reset {
            print("Reseting")
            self.canLoadMorePages = true
            self.lastDocument = nil
            self.adArray.removeAll()
            self.items.removeAll()
        }

        let fstore = Firestore.firestore()

        var query: Query!
        let limit = 10

        if let lastDocument = lastDocument {
            query = fstore.collection("recipes")
                .order(by: "dateAdded", descending: true)
                .start(atDocument: lastDocument)
                .limit(to: limit)
        } else {
            query = fstore.collection("recipes")
                .order(by: "dateAdded", descending: true)
                .limit(to: limit)
        }

        query.getDocuments { [self] snap, err in
            self.isLoadingPage = false
            if let err = err {
                UserResponse.displayError(msg: err.localizedDescription)
                return
            }
            guard let snap = snap else { return }
            var recipes = [Recipe]()
            for doc in snap.documents {
                if let recipe = try? doc.data(as: Recipe.self) {
                    recipes.append(recipe)
                }
            }
            guard let last = snap.documents.last else { // There is no more pages
                return
            }
            if recipes.count <= 1 { // For some reason it returns 1 when final one
                self.canLoadMorePages = false
            }
            self.lastDocument = last
            if let user = YKNetworkManager.shared.currentUser {
                recipes = recipes.filter { $0.checkAllergenes(allergenes: user.allergenes) }
            }
            for item in recipes {
                if !self.items.contains(item) {
                    self.items.append(item)
                }
                self.adArray[item] = self.recipeViewModel.shouldShowAd()
            }
            print(recipes.count.description + " new recipes loaded")
        }
    }
}
