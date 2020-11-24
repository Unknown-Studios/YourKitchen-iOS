//
//  YKNetwork+FeedItems.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public extension YKNetworkManager {
    enum FeedItems {
        public static func add(feedItem: FeedItem, _ completion: @escaping (FeedItem) -> Void) {
            guard YKNetworkManager.shared.currentUser != nil else {
                return
            }
            let fstore = Firestore.firestore()
            var tmpFeedItem = feedItem
            tmpFeedItem.reference = fstore.collection("feeditems").document(feedItem.id)

            do {
                try tmpFeedItem.reference!.setData(from: tmpFeedItem) { err in
                    if let err = err {
                        UserResponse.displayError(msg: "FeedItems/add " + err.localizedDescription)
                        return
                    }
                    completion(feedItem)
                }
            } catch {
                UserResponse.displayError(msg: "FeedItems/add " + error.localizedDescription)
            }
        }

        public static func get(_ completion: @escaping ([FeedItem]) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            let fstore = Firestore.firestore()
            fstore.collection("feeditems").getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "FeedItems/get " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    var feeditems = [FeedItem]()
                    for doc in snap.documents {
                        if let feeditem = try? doc.data(as: FeedItem.self) {
                            feeditems.append(feeditem)
                        }
                    }
                    let tmpFeedItems = feeditems.filter { fitem in
                        user.following.contains(where: { $0 == fitem.owner.id }) || user.id == fitem.owner.id
                    }
                    completion(tmpFeedItems)
                }
            }
        }
    }
}
