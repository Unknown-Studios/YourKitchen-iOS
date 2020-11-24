//
//  YKNetwork+Ingredients.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Firebase
import Foundation
import FirebaseFirestore

public extension YKNetworkManager {
    enum Ingredients {
        public static var cache = NSCache<NSString, AnyObject>()

        public static func get(cache: Bool = true, completion: @escaping ([Ingredient]) -> Void) {
            if cache {
                if let item = Ingredients.cache.object(forKey: "ingredients") as? [Ingredient] {
                    return completion(item)
                }
            }
            let fstore = Firestore.firestore()
            fstore.collection("ingredients")
                .getDocuments { snap, err in
                    if let err = err {
                        UserResponse.displayError(msg: "Ingredients/get " + err.localizedDescription)
                        return
                    }
                    if let snap = snap {
                        var ingredients = [Ingredient]()
                        for doc in snap.documents {
                            if let ingredient = try? doc.data(as: Ingredient.self) {
                                ingredients.append(ingredient)
                            }
                        }
                        print("Fetched " + ingredients.count.description + " ingredients")
                        Ingredients.cache.setObject(ingredients as NSArray, forKey: "ingredients")
                        completion(ingredients)
                    }
                }
        }

        public static func add(_ ingredient: Ingredient, completion: @escaping (Ingredient) -> Void) {
            print("Adding ingredient..")
            let fstore = Firestore.firestore()
            let ref = fstore.collection("ingredients").document(ingredient.id)
            ingredient.reference = ref

            Ingredients.get { ingredients in
                //If we don't already have a ingredient where the name is the same (Should be handled on server)
                if ingredients.filter({ $0.name.lowercased() == ingredient.name.lowercased() }).count > 0 {
                    completion(ingredient)
                    return
                }
                _ = try? ref.setData(from: ingredient) { err in
                    if let err = err {
                        UserResponse.displayError(msg: "Ingredients/add " + err.localizedDescription)
                        return
                    }
                    print("Ingredient added")
                    cache.removeAllObjects() // We need to refetch cache if we have added something new
                    completion(ingredient)
                }
            }
        }

        public static func match(ingredients: [Ingredient], storedIngredients: [Ingredient]) -> [Ingredient] {
            let fetchedIngredients = storedIngredients.filter { (ingredient) -> Bool in
                ingredients.contains(where: { $0 == ingredient })
            }
            var finalIngredients = [Ingredient]()
            for fing in zip(fetchedIngredients.sorted(by: { $0.name > $1.name }), ingredients.sorted(by: { $0.name > $1.name })) {
                let ingredient = fing.0
                ingredient.amount = fing.1.amount
                ingredient.count = fing.1.count
                ingredient.unit = fing.1.unit
                ingredient.type = fing.1.type

                if ingredient.amount > 0 {
                    finalIngredients.append(ingredient)
                }
            }
            return finalIngredients
        }
    }
}
