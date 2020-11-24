//
//  SearchViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseAuth
import Foundation
import Fuse

public class SearchViewModel {
    public enum SearchType {
        case users
        case recipes
    }

    func search(query: String, array: [SearchResult]) -> [SearchResult] {
        let fuse = Fuse()

        // Fix search results:
        let recipes = array.filter {
            $0.recipe != nil
        }.map { $0.recipe! }
        let recipeStrings = recipes.map(\.name)
        let users = array.filter {
            if let user = Auth.auth().currentUser {
                return $0.user != nil && $0.user!.id != user.uid
            }
            return $0.user != nil
        }.map { $0.user! }
        let userStrings = users.map(\.name)
        let ingredients = array.filter {
            $0.ingredient != nil
        }.map { $0.ingredient! }
        let ingredientStrings = ingredients.map(\.name)

        var recipeResults = [Fuse.SearchResult]()
        recipeResults.append(contentsOf: fuse.search(query, in: recipeStrings))
        var userResults = [Fuse.SearchResult]()
        userResults.append(contentsOf: fuse.search(query, in: userStrings))
        var ingredientResults = [Fuse.SearchResult]()
        ingredientResults.append(contentsOf: fuse.search(query, in: ingredientStrings))

        var resultsArray = [SearchResult]()
        for a in 0 ..< min(recipeResults.count, 50) {
            let item = recipeResults[a]
            resultsArray.append(SearchResult(recipe: recipes[item.index], score: item.score))
        }
        for b in 0 ..< min(userResults.count, 50) {
            let item = userResults[b]
            resultsArray.append(SearchResult(user: users[item.index], score: item.score))
        }
        for c in 0 ..< min(ingredientResults.count, 50) {
            let item = ingredientResults[c]
            resultsArray.append(SearchResult(ingredient: ingredients[item.index], score: item.score))
        }
        let finalResults = resultsArray.sorted { (item1, item2) -> Bool in
            item1.score < item2.score
        }
        return finalResults
    }
}
