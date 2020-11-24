//
//  YKNetwork+Notifications.swift
//  YourKitchen
//
//  Created by Markus Moltke on 10/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension YKNetworkManager {
    enum Notifications {
        public static var listeners = [String: ListenerRegistration]()

        public static func get(_ completion: @escaping ([YKNotification]) -> Void) {
            guard YKNetworkManager.shared.currentUser != nil else {
                return
            }

            YKNetworkManager.Invitations.getMyInvitations { invitations in
                var notifications = [YKNotification]()
                for invi in invitations {
                    let notification = YKNotification(title: "Invitation Received", message: "You have received an invitation to join " + invi.owner.name + "'s " + invi.type, action: invi)
                    notifications.append(notification)
                }
                completion(notifications)
            }
        }
        
        public static func removeListener(_ id: String) {
            if listeners[id] != nil {
                listeners[id]!.remove()
                listeners[id] = nil
            }
        }

        public static func getListener(id: String, _ completion: @escaping ([YKNotification]) -> Void) {
            if listeners[id] != nil {
                listeners[id]!.remove()
                listeners[id] = nil
            }
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            let fstore = Firestore.firestore()
            listeners[id] = fstore.collection("invitations").whereField("ownerId", isEqualTo: user.id).addSnapshotListener { _, err in
                if let err = err {
                    UserResponse.displayError(msg: "Notifications/getListener " + err.localizedDescription)
                    return
                }
                get { notifications in
                    completion(notifications)
                }
            }
        }
    }
}
