//
//  Interests+YKNetwork.swift
//  YourKitchen
//
//  Created by Markus Moltke on 15/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore

public extension YKNetworkManager {
    enum Interests {
        /**
          Used to get the interests from the server
         - Parameters:
             - completion: ([String : Int], [String : Int]) -> () Callback for getting the interests
             - likes: Likes is the thing that this person has made
             - ratings: Ratings are the things that the person has rated.
              */
        public static func get(completion: @escaping (_ likes: [String: Int], _ ratings: [String: Int]) -> Void) {
            let fstore = Firestore.firestore()

            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            fstore.collection("interests").whereField("ownerId", isEqualTo: user.id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Interests/Get/Get: " + err.localizedDescription)
                    return
                }

                guard let snap = snap else { return }
                if snap.documents.count == 0 {
                    completion([String: Int](), [String: Int]())
                    return
                }
                let doc = snap.documents[0]
                if let interests = try? doc.data(as: YKInterests.self) {
                    completion(interests.likes, interests.ratings)
                    return
                }
                UserResponse.displayError(msg: "Interests/Get: Unable to load data")
            }
        }

        /**
         Used to keep records of the likes and ratings that this user has.

         - Parameters:
            - likes: The things that the user has made divided into category
            - ratings: The things that the user has added their rating to divided into category
            - completion: Called upon succesful update
         */
        public static func update(likes: [String: Int] = [String: Int](), ratings: [String: Int] = [String: Int](), completion: (() -> Void)? = nil) {
            let fstore = Firestore.firestore()

            if likes.count == 0, ratings.count == 0 {
                print("Interests/Update: You have to define at least a single like")
                return
            }

            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            fstore.collection("interests").whereField("ownerId", isEqualTo: user.id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Interests/Update/Get: " + err.localizedDescription)
                    return
                }
                guard let snap = snap else { return }

                if snap.documents.count > 0 { // Document already exists
                    let doc = snap.documents[0]

                    guard let interests = try? doc.data(as: YKInterests.self) else { return }
                    // Handle likes
                    for like in likes {
                        if interests.likes[like.key] == nil {
                            interests.likes[like.key] = 0
                        }
                        interests.likes[like.key]! += like.value
                    }

                    // Handle ratings
                    for rating in ratings {
                        if interests.ratings[rating.key] == nil {
                            interests.ratings[rating.key] = 0
                        }
                        interests.ratings[rating.key]! += rating.value
                    }

                    // Submit the data
                    doc.reference.updateData(["likes": interests.likes, "ratings": interests.ratings]) { err in
                        if let err = err {
                            UserResponse.displayError(msg: "Interests/Update/Submit: " + err.localizedDescription)
                            return
                        }
                        if let completion = completion {
                            completion()
                        }
                    }
                } else { // Document doesn't exist
                    fstore.collection("interests").addDocument(data: ["id": UUID().uuidString, "ownerId": user.id, "likes": likes, "ratings": ratings]) { err in
                        if let err = err {
                            UserResponse.displayError(msg: "Interests/Update/Add: " + err.localizedDescription)
                            return
                        }
                        if let completion = completion {
                            completion()
                        }
                    }
                }
            }
        }
    }
}
