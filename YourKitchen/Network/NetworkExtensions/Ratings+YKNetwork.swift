//
//  YKNetwork+Ratings.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension YKNetworkManager {
    enum Ratings {
        public static func get(recipe: Recipe, completion: @escaping (Int) -> Void) {
            let fstore = Firestore.firestore()
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            fstore.collection("ratings").whereField("ownerId", isEqualTo: user.id).whereField("recipeId", isEqualTo: recipe.id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Ratings/get " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    if snap.count > 0 {
                        let rating = snap.documents[0].data()["rating"] as? Int ?? 0
                        completion(rating)
                    } else {
                        completion(0)
                    }
                }
            }
        }

        public static func update(rating: Int, recipe: Recipe) {
            let fstore = Firestore.firestore()
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            fstore.collection("ratings").whereField("ownerId", isEqualTo: user.id).whereField("recipeId", isEqualTo: recipe.id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Ratings/update " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    if snap.count > 0 {
                        snap.documents[0].reference.updateData(["rating": rating]) { err in
                            if let err = err {
                                UserResponse.displayError(msg: "Ratings/update " + err.localizedDescription)
                                return
                            }
                        }
                    } else {
                        var tmpRating = [String: Any]()
                        tmpRating["rating"] = rating
                        tmpRating["ownerId"] = user.id
                        tmpRating["recipeId"] = recipe.id
                        tmpRating["id"] = UUID().uuidString
                        fstore.collection("ratings").addDocument(data: tmpRating) { err in
                            if let err = err {
                                UserResponse.displayError(msg: "Ratings/update " + err.localizedDescription)
                                return
                            }
                            if rating == 1 {
                                Messaging.sendPushNotification(user: recipe.author,
                                                               title: recipe.author.name + " liked your post",
                                                               message: "You've got a new like, go take a look in the app.",
                                                               data: ["recipe": recipe.id])
                            }
                        }
                    }
                }
            }
        }
    }
}
