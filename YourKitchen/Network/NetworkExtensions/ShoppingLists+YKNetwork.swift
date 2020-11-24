//
//  ShoppingLists+YKNetwork.swift
//  YourKitchen
//
//  Created by Markus Moltke on 15/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension YKNetworkManager {
    enum ShoppingLists {
        /**
         Used to get the shopping list connected to the refrigerator
         */
        public static func get(_ refrigeratorOwner: String, _ completion: @escaping (ShoppingList?) -> Void) {
            let fstore = Firestore.firestore()
            fstore.collection("shoppinglists").whereField("ownerId", isEqualTo: refrigeratorOwner).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "ShoppingLists/get " + err.localizedDescription)
                    return
                }
                guard let snap = snap else {
                    return
                }
                if snap.count > 0 {
                    if let shoppingList = try? snap.documents[0].data(as: ShoppingList.self) {
                        completion(shoppingList)
                        return
                    }
                }

                completion(nil)
            }
        }

        public static func update(shoppingList: ShoppingList, _ completion: (() -> Void)? = nil) {
            guard YKNetworkManager.shared.currentUser != nil else {
                return
            }

            let fstore = Firestore.firestore()
            var tmpShoppingList = shoppingList
            tmpShoppingList.reference = fstore.collection("shoppinglists").document(shoppingList.id)
            _ = try? tmpShoppingList.reference!.setData(from: tmpShoppingList, completion: { (err) in
                if let err = err {
                    UserResponse.displayError(msg: err.localizedDescription)
                    return
                }
                if let c = completion {
                    c()
                }
            })
        }
    }
}
