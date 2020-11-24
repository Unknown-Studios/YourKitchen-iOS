//
//  YKNetworkRecipes.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

public extension YKNetworkManager {
    enum Recipes {
        public static var cache = NSCache<NSString, AnyObject>()

        public static func get(id: String, cache: Bool = true, completion: @escaping (Recipe) -> Void) {
            if cache {
                if let item = Recipes.cache.object(forKey: id as NSString) as? Recipe {
                    completion(item)
                }
            }
            let fstore = Firestore.firestore()
            fstore.collection("recipes").whereField("id", isEqualTo: id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Recipes/get " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    snap.documents.forEach { doc in
                        if let data = try? doc.data(as: Recipe.self) {
                            completion(data)
                        }
                    }
                }
            }
        }

        public static func getAll(cache: Bool = true, completion: @escaping ([Recipe]) -> Void) {
            let fstore = Firestore.firestore()
            if cache {
                if let recipesArray = Recipes.cache.object(forKey: "recipes") as? [Recipe] {
                    return completion(recipesArray)
                }
            }
            fstore.collection("recipes").getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Recipes/getAll " + err.localizedDescription)
                    return
                }
                print("Got users and ingredients")
                if let snap = snap {
                    var recipes = [Recipe]()
                    for doc in snap.documents {
                        if let recipe = try? doc.data(as: Recipe.self) {
                            recipes.append(recipe)
                        }
                    }
                    if let user = YKNetworkManager.shared.currentUser {
                        let newRecipes = recipes.filter { $0.checkAllergenes(allergenes: user.allergenes) }
                        Recipes.cache.setObject(newRecipes as NSArray, forKey: "recipes")
                        completion(newRecipes)
                        print("Fetched " + recipes.count.description + " recipes")
                    } else {
                        Recipes.cache.setObject(recipes as NSArray, forKey: "recipes")
                        completion(recipes)
                        print("Fetched " + recipes.count.description + " recipes")
                    }
                }
            }
        }

        public static func delete(recipeId: String, completion: @escaping () -> Void) {
            print("Deleting recipe..")
            let fstore = Firestore.firestore()
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            fstore.collection("recipes").whereField("author.id", isEqualTo: user.id).whereField("id", isEqualTo: recipeId).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Recipes/delete " + err.localizedDescription)
                    return
                }
                guard let snap = snap, snap.documents.count > 0 else { return }
                let doc = snap.documents[0]
                let data = doc.data()
                let batch = fstore.batch()
                batch.deleteDocument(doc.reference)
                if let recipeId = data["id"] as? String {
                    fstore.collection("feeditems").whereField("recipe.id", isEqualTo: recipeId).getDocuments { (feedItemsSnap, err) in
                        if let err = err {
                            UserResponse.displayError(msg: "Recipes/FeedItems/delete " + err.localizedDescription)
                            return
                        }
                        guard let feedItemsSnap = feedItemsSnap else { return }
                        if (feedItemsSnap.documents.count > 0) {
                            let feedDoc = snap.documents[0]
                            batch.deleteDocument(feedDoc.reference)
                        }
                        batch.commit { err in
                            if let err = err {
                                UserResponse.displayError(msg: err.localizedDescription)
                                return
                            }
                            completion()
                        }
                    }
                }
            }
        }

        public static func add(recipe: Recipe, _ image: UIImage? = nil, completion: @escaping (Recipe) -> Void) {
            print("Adding recipe..")
            if let image = image {
                let tmpImage = image.imageWithSize(size: CGSize(width: 500, height: 500))
                let storage = Storage.storage()
                let ref = storage.reference(withPath: "recipe/" + UUID().uuidString + ".jpg")

                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                if let pngData = tmpImage.jpegData(compressionQuality: 0.75) {
                    ref.putData(pngData, metadata: metadata) { _, err in
                        if let err = err {
                            UserResponse.displayError(msg: "Recipes/add/image" + err.localizedDescription)
                            return
                        }
                        ref.downloadURL { url, err in
                            if let err = err {
                                UserResponse.displayError(msg: "Recipes/add/url" + err.localizedDescription)
                                return
                            }
                            if let url = url {
                                self.finishAdding(url.absoluteString, recipe: recipe, completion: completion)
                            } else {
                                self.finishAdding(recipe: recipe, completion: completion)
                            }
                        }
                    }
                } else {
                    finishAdding(recipe: recipe, completion: completion)
                }
            } else {
                finishAdding(recipe: recipe, completion: completion)
            }
        }

        private static func finishAdding(_ url: String = "", recipe: Recipe, completion: @escaping (Recipe) -> Void) {
            let fstore = Firestore.firestore()
            let newRecipe = recipe
            newRecipe.image = url
            newRecipe.reference = fstore.collection("recipes").document(recipe.id)
            try? newRecipe.reference!.setData(from: newRecipe) { err in
                if let err = err {
                    UserResponse.displayError(msg: "Recipes/add" + err.localizedDescription)
                    return
                }
                print("Recipe added")
                let feedItem = FeedItem(owner: newRecipe.author, description: nil, recipe: newRecipe)
                FeedItems.add(feedItem: feedItem) { _ in
                }

                completion(newRecipe)
            }
        }

        public static func update(recipe: Recipe, image: UIImage? = nil, _ completion: @escaping (Recipe) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            let finishUpdating: (Recipe, String?) -> Void = { curRecipe, imageUrl in
                let newRecipe = curRecipe
                if let image = imageUrl {
                    newRecipe.image = image
                }
                let fstore = Firestore.firestore()
                fstore.collection("recipes").whereField("id", isEqualTo: curRecipe.id).whereField("author", isEqualTo: user.id).getDocuments { snap, err in
                        if let err = err {
                            UserResponse.displayError(msg: "Recipes/update " + err.localizedDescription)
                            return
                        }
                        guard let snap = snap else {
                            return
                        }
                        let batch = fstore.batch()
                        snap.documents.forEach { doc in
                            _ = try? batch.setData(from: newRecipe, forDocument: doc.reference)
                        }
                        batch.commit { err in
                            if let err = err {
                                UserResponse.displayError(msg: "Recipes/update/commit " + err.localizedDescription)
                                return
                            }
                            completion(curRecipe)
                        }
                    }
                //}
            }

            if let image = image {
                let tmpImage = image.imageWithSize(size: CGSize(width: 500, height: 500))
                let storage = Storage.storage()
                let ref = storage.reference(withPath: "recipe/" + UUID().uuidString + ".jpg")

                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                if let jpegData = tmpImage.jpegData(compressionQuality: 0.75) {
                    ref.putData(jpegData, metadata: metadata) { _, err in
                        if let err = err {
                            UserResponse.displayError(msg: "Recipes/update " + err.localizedDescription)
                            return
                        }
                        ref.downloadURL { url, err in
                            if let err = err {
                                UserResponse.displayError(msg: "Recipes/update/url " + err.localizedDescription)
                                return
                            }
                            if let url = url {
                                finishUpdating(recipe, url.absoluteString)
                            } else {
                                finishUpdating(recipe, nil)
                            }
                        }
                    }
                } else {
                    finishUpdating(recipe, nil)
                }
            } else {
                finishUpdating(recipe, nil)
            }
        }

        public static func getRange(lastDocument: DocumentSnapshot?, limit: Int, completion: @escaping (DocumentSnapshot, [Recipe]) -> Void) {
            let fstore = Firestore.firestore()

            var query: Query!

            if let lastDocument = lastDocument {
                query = fstore.collection("recipes")
                    .order(by: "dateAdded")
                    .start(atDocument: lastDocument)
                    .limit(to: limit)
            } else {
                query = fstore.collection("recipes")
                    .order(by: "dateAdded")
                    .limit(to: limit)
            }

            query.getDocuments { snap, err in
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
                if let user = YKNetworkManager.shared.currentUser {
                    let newRecipes = recipes.filter { $0.checkAllergenes(allergenes: user.allergenes) }
                    completion(last, newRecipes)
                } else {
                    completion(last, recipes)
                }
            }
        }
    }
}
