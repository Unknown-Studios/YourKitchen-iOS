//
//  SelectRecipeViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 15/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import Foundation

public class SelectRecipeViewModel {
    func getInterests(amount: Int = 3, _ completion: @escaping ([Recipe]) -> Void) {
        let fstore = Firestore.firestore()

        YKNetworkManager.Interests.get { likes, ratings in
            // Ratings should count 2 times compared to likes.

            var resultDict = [String: Double]()

            for like in likes {
                if like.key == "other" {
                    continue
                }
                if resultDict[like.key] == nil {
                    resultDict[like.key] = 0
                }
                resultDict[like.key]! += (Double(like.value) * (1 / 3)) // Likes counts as 0.33
            }

            for rating in ratings {
                if rating.key == "other" {
                    continue
                }
                if resultDict[rating.key] == nil {
                    resultDict[rating.key] = 0
                }
                resultDict[rating.key]! += (Double(rating.value) * (2 / 3)) // Rating counts as 0.66
            }

            let sortedResults = resultDict.sorted { (item1, item2) -> Bool in
                item1.value > item2.value
            }

            //Get the 3 first items in the array
            let finalResults = sortedResults.prefix(3)

            var itemsTypes = [String]()
            for (k, _) in finalResults {
                itemsTypes.append(k)
            }

            guard itemsTypes.count > 0 else {
                completion([])
                return
            } // We need at least 1 item in itemsTypes for firestore not to crash

            fstore.collection("recipes").whereField("type", in: itemsTypes).getDocuments { snap, err in // We must get 3 correct ones within
                if let err = err {
                    UserResponse.displayError(msg: "SelectRecipeViewModel: " + err.localizedDescription)
                    completion([])
                    return
                }
                guard let snap = snap else {
                    completion([])
                    return
                }
                var snapDocuments = snap.documents // Make constant into variable

                YKNetworkManager.Users.getAll { users in
                    var resultsArray = [Recipe]()
                    var triesLeft = amount * 2
                    while resultsArray.count <= amount, snapDocuments.count > 0, triesLeft > 0 { // We need "amount" items for the recommended, but if we don't have 3 items of that type don't break
                        triesLeft -= 1
                        if let doc = snapDocuments.randomElement(), let recipe = try? doc.data(as: Recipe.self) {
                            if let userId = doc.data()["author"] as? String, let author = users.first(where: { $0.id == userId }) {
                                if !resultsArray.contains(where: { $0.type == recipe.type }) {
                                    recipe.author = author
                                    resultsArray.append(recipe)
                                    continue
                                }
                                // Remove to prevent infinite loop
                            }
                            snapDocuments.removeAll { (item) -> Bool in
                                item == doc
                            }
                        }
                    }
                    completion(resultsArray)
                }
            }
        }
    }
}
