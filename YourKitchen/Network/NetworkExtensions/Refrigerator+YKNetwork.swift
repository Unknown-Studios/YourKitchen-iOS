//
//  YKNetwork+Refrigerator.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Firebase
import Foundation

public extension YKNetworkManager {
    enum Refrigerators {
        public static var cache = NSCache<NSString, Refrigerator>()

        public static func get(id: String? = nil, cache: Bool = true, completion: @escaping (Refrigerator?) -> Void) {
            let fstore = Firestore.firestore()
            guard let user = Auth.auth().currentUser else {
                completion(nil)
                return
            }
            if id == nil, cache {
                if let item = Refrigerators.cache.object(forKey: user.uid as NSString) {
                    return completion(item)
                }
            }
            fstore.collection("refrigerators")
                .whereField("ownerId", isEqualTo: id ?? user.uid).getDocuments { snap, _ in
                    if let snap = snap {
                        if snap.documents.count > 0 {
                            if let refrigerator = try? snap.documents[0].data(as: Refrigerator.self) {
                                if refrigerator.shareID == nil || id != nil {
                                    Refrigerators.cache.setObject(refrigerator, forKey: user.uid as NSString)
                                    return completion(refrigerator)
                                } else {
                                    self.get(id: refrigerator.shareID) { refrigerator in
                                        completion(refrigerator)
                                    }
                                    return
                                }
                            }
                        }
                    }
                    completion(nil)
                }
        }

        public static func getSharedUsers(_ completion: @escaping ([YKUser]) -> Void) {
            guard let user = Auth.auth().currentUser else {
                return
            }

            getAll { refrigerators in
                Users.getAll { users in
                    isHost { value in
                        var tmpUsers = [YKUser]()
                        if value { // If we are the host, we need to find everybody else
                            // Get refrigerators that we either own or are the shareID of
                            let newRefrigerators = refrigerators.filter {
                                $0.shareID == user.uid || $0.ownerId == user.uid
                            }.map(\.shareID)
                            tmpUsers.append(contentsOf: users.filter {
                                newRefrigerators.contains($0.id)
                            })
                        } else { // If we aren't the host, find the host, then find everybody else
                            if let ownRefrigerator = refrigerators.filter({ $0.ownerId == user.uid }).first {
                                if let hostRefrigerator = refrigerators.filter({ $0.ownerId == ownRefrigerator.shareID }).first {
                                    let newRefrigerators = refrigerators.filter {
                                        $0.shareID == hostRefrigerator.ownerId || $0.ownerId == hostRefrigerator.ownerId
                                    }.map(\.shareID)
                                    tmpUsers.append(contentsOf: users.filter {
                                        newRefrigerators.contains($0.id)
                                    })
                                }
                            }
                        }
                        completion(tmpUsers)
                    }
                }
            }
        }

        public static func isHost(_ completion: @escaping (Bool) -> Void) {
            guard let user = Auth.auth().currentUser else {
                return
            }

            get(cache: false) { refrigerator in
                // Works because the refrigerator will only be the users own if they are the host.
                if let refrigerator = refrigerator {
                    completion(refrigerator.ownerId == user.uid)
                }
            }
        }

        public static func add(_ completion: @escaping (Refrigerator) -> Void) {
            let fstore = Firestore.firestore()
            guard let user = Auth.auth().currentUser else {
                return
            }
            let refrigerator = Refrigerator(ownerId: user.uid, ingredients: [])
            refrigerator.reference = fstore.collection("refrigerators").document(refrigerator.id)
            _ = try? refrigerator.reference!.setData(from: refrigerator) { (err) in
                if let err = err {
                    UserResponse.displayError(msg: err.localizedDescription)
                    return
                }
            }
        }

        public static func update(user: YKUser? = nil, shareID: String?, _ completion: (() -> Void)? = nil) {
            guard Auth.auth().currentUser != nil else {
                return
            }

            YKNetworkManager.shared.updateAll("refrigerators", anotherUser: user, values: ["shareID": shareID ?? FieldValue.delete()]) {
                if let completion = completion {
                    completion()
                }
            }
        }

        public static func update(refrigerator: Refrigerator, completion: (() -> Void)? = nil) {
            let fstore = Firestore.firestore()
            guard Auth.auth().currentUser != nil else {
                return
            }
            let tmpRefrigerator = refrigerator
            if tmpRefrigerator.reference == nil {
                tmpRefrigerator.reference = fstore.collection("refrigerators").document(tmpRefrigerator.id)
            }
            _ = try? tmpRefrigerator.reference!.setData(from: tmpRefrigerator, completion: { (err) in
                if let err = err {
                    UserResponse.displayError(msg: "Refrigerator/update " + err.localizedDescription)
                    return
                }
            })
        }

        /**
         Used to get all refrigerators, for internal use.
         */
        fileprivate static func getAll(_ completion: @escaping ([Refrigerator]) -> Void) {
            let fstore = Firestore.firestore()
            fstore.collection("refrigerators").getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Ingredients/getAll " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    var tmpRefrigerators = [Refrigerator]()
                    snap.documents.forEach { doc in
                        if let refrigerator = try? doc.data(as: Refrigerator.self) {
                            tmpRefrigerators.append(refrigerator)
                        }
                    }
                    completion(tmpRefrigerators)
                }
            }
        }
    }
}
