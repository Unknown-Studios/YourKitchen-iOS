//
//  YKNetwork+Mealplans.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension YKNetworkManager {
    enum Mealplans {
        public static var cache = NSCache<NSString, Mealplan>()

        public static func get(id: String? = nil, cache: Bool = true, completion: @escaping ([Mealplan]) -> Void) {
            let fstore = Firestore.firestore()
            guard let user = YKNetworkManager.shared.currentUser else {
                completion([])
                return
            }
            if cache {
                if let id = id {
                    if let item = Mealplans.cache.object(forKey: id as NSString) {
                        return completion([item])
                    }
                } else {
                    if let item = Mealplans.cache.object(forKey: user.id as NSString) {
                        return completion([item])
                    }
                }
            }
            fstore.collection("mealplans")
                .whereField("ownerId", isEqualTo: id ?? user.id).getDocuments { snap, err in
                    if let err = err {
                        UserResponse.displayError(msg: "Mealplans/get " + err.localizedDescription)
                        return
                    }
                    if let snap = snap {
                        if snap.count > 0 {
                            let doc = snap.documents[0]
                            // If somebody else is sharing their mealplan and it doesn't nest above 1
                            var tmpMealplans = [Mealplan]()
                            if let mealplan = try? doc.data(as: Mealplan.self) {
                                tmpMealplans.append(mealplan)
                                if mealplan.shareIDs.count > 0 {
                                    fstore.collection("mealplans").whereField("ownerId", in: mealplan.shareIDs).getDocuments { (snap, err) in
                                        if let err = err {
                                            UserResponse.displayError(msg: err.localizedDescription)
                                            return
                                        }
                                        guard let snap = snap else { return }
                                        snap.documents.forEach({ (doc) in
                                            if let mealplan = try? doc.data(as: Mealplan.self) {
                                                tmpMealplans.append(mealplan)
                                                Mealplans.cache.setObject(mealplan, forKey: mealplan.ownerId as NSString)
                                            }
                                        })
                                        return completion(tmpMealplans)
                                    }
                                } else {
                                    Mealplans.cache.setObject(tmpMealplans[0], forKey: tmpMealplans[0].ownerId as NSString)
                                    return completion(tmpMealplans) // Pass "Your Mealplan"
                                }
                            } else {
                                print("Couldn't convert mealplan")
                                completion([Mealplan(meals: Mealplan.emptyMealplan)])
                            }
                        } else {
                            completion([Mealplan(meals: Mealplan.emptyMealplan)])
                        }
                    }
                }
        }

        /**
         Used to get the mealplans that we are following
         */
        public static func getShared(_ completion: @escaping ([SocialMealplan]) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            let fstore = Firestore.firestore()
            fstore.collection("mealplans").whereField("shareIDs", arrayContains: user.id).getDocuments { (snap, err) in
                if let err = err {
                    UserResponse.displayError(msg: "mealplans/shared/get" + err.localizedDescription)
                    return
                }
                guard let snap = snap else { return }
                Users.getAll { users in
                    var sharedMealplans = [SocialMealplan]()
                    snap.documents.forEach({ (doc) in
                        if let mealplan = try? doc.data(as: Mealplan.self), let owner = users.first(where: { $0.id == mealplan.ownerId }) {
                            sharedMealplans.append(SocialMealplan(owner: owner, mealplan: mealplan))
                        }
                    })
                    completion(sharedMealplans)
                }
            }
        }

        /**
         Used to get the users that are following us.
         */
        public static func getSharedUsers(_ completion: @escaping ([YKUser]) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            getAll { mealplans in
                Users.getAll { users in
                    let sharedMealplans = mealplans.filter {
                        $0.shareIDs.contains(user.id)
                    }.map(\.ownerId)
                    completion(users.filter {
                        sharedMealplans.contains($0.id)
                    })
                }
            }
        }

        public static func deleteMyId(owner: YKUser, _ completion: @escaping () -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            let fstore = Firestore.firestore()
            fstore.collection("mealplans").whereField("ownerId", isEqualTo: owner.id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Mealplans/deleteMyID " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    let batch = fstore.batch()
                    snap.documents.forEach { doc in
                        if var sharedIDs = doc.data()["shareIDs"] as? [String] {
                            sharedIDs.removeAll(where: { $0 == user.id })
                            doc.reference.updateData(["shareIDs": sharedIDs])
                        }
                    }
                    batch.commit { err in
                        if let err = err {
                            UserResponse.displayError(msg: "Mealplans/deleteMyID " + err.localizedDescription)
                            return
                        }
                        completion()
                    }
                }
            }
        }

        /**
         Used to update our own mealplan object
         */
        public static func update(_ mealplan: Mealplan, completion: @escaping (Mealplan) -> Void) {
            let fstore = Firestore.firestore()
            if (mealplan.reference == nil) {
                mealplan.reference = fstore.collection("mealplans").document(mealplan.id)
            }
            print(mealplan.meals[0].recipe.name)
            _ = try? mealplan.reference!.setData(from: mealplan, completion: { (err) in
                if let err = err {
                    UserResponse.displayError(msg: err.localizedDescription)
                    return
                }
                completion(mealplan)
            })
        }

        fileprivate static func getAll(_ completion: @escaping ([Mealplan]) -> Void) {
            let fstore = Firestore.firestore()

            fstore.collection("mealplans").getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Mealplans/getAll " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    var mealplans = [Mealplan]()
                    snap.documents.forEach { doc in
                        if let mealplan = try? doc.data(as: Mealplan.self) {
                            mealplans.append(mealplan)
                        }
                    }
                    completion(mealplans)
                }
            }
        }
    }
}
