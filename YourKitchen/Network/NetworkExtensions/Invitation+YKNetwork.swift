//
//  YKNetwork+Invitation.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseFirestore
import Foundation

public extension YKNetworkManager {
    enum Invitations {
        /**
         Used to get invitations sent to this user.
         */
        public static func getMyInvitations(_ completion: @escaping ([Invitation]) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            getAll { invitations in
                completion(invitations.filter {
                    $0.other.id == user.id
                })
            }
        }

        /**
         Used to get all invitations
         */
        fileprivate static func getAll(_ completion: @escaping ([Invitation]) -> Void) {
            let fstore = Firestore.firestore()
            fstore.collection("invitations").getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Invitation/getAll " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    var invitations = [Invitation]()
                    snap.documents.forEach { doc in
                        if let invitation = try? doc.data(as: Invitation.self) {
                            invitations.append(invitation)
                        }
                    }
                    completion(invitations)
                }
            }
        }

        /**
         Used to get the invitations that this user has sent.
         */
        public static func getInvitations(type: String? = nil, _ completion: @escaping ([Invitation]) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            let fstore = Firestore.firestore()
            fstore.collection("invitations").whereField("owner.id", isEqualTo: user.id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Invitation/getInvitations " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    var invitations = [Invitation]()
                    snap.documents.forEach { doc in
                        if let invitation = try? doc.data(as: Invitation.self) {
                            invitations.append(invitation)
                        }
                    }
                    if let type = type {
                        completion(invitations.filter {
                            $0.type == type
                        })
                    } else {
                        completion(invitations)
                    }
                }
            }
        }

        public static func add(to user: YKUser, type: String, _ completion: @escaping (Invitation) -> Void) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            let invitation = Invitation(owner: user, other: user, type: type)

            let fstore = Firestore.firestore()
            fstore.collection("invitations").whereField("owner.id", isEqualTo: user.id).whereField("type", isEqualTo: invitation.type).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Invitation/add " + err.localizedDescription)
                    return
                }
                if let snap = snap, snap.count > 0 {
                    var found = false
                    snap.documents.forEach { (doc) in
                        if let otherInvitation = try? doc.data(as: Invitation.self) {
                            if otherInvitation.other == user {
                                found = true
                            }
                        }
                    }
                    if !found {
                        addFinish(invitation: invitation, completion)
                    }
                } else {
                    self.addFinish(invitation: invitation, completion)
                }
            }
        }

        fileprivate static func addFinish(invitation: Invitation, _ completion: @escaping (Invitation) -> Void) {
            let fstore = Firestore.firestore()
            _ = try? fstore.collection("invitations").document(invitation.id).setData(from: invitation) { err in
                if let err = err {
                    UserResponse.displayError(msg: err.localizedDescription)
                    return
                }
                if let user = YKNetworkManager.shared.currentUser {
                    Messaging.sendPushNotification(user: invitation.other, title: "Invitation Received", message: "You just received an invitation to join " + user.name + "s " + invitation.type)
                }
                completion(invitation)
            }
        }

        public static func handle(invitation: Invitation, status: InvitationStatus) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            print("Handling notification: " + invitation.type)

            switch status {
            case .accept:
                if invitation.type == "mealplan" {
                    // Get own mealplan
                    Mealplans.get { mealplans in
                        if mealplans.count > 0 {
                            let ownMealplan = mealplans[0]
                            ownMealplan.shareIDs.append(invitation.owner.id)
                            print("Updating mealplan")
                            YKNetworkManager.shared.updateAll("mealplans", values: ["shareIDs": ownMealplan.shareIDs]) {
                                Messaging.sendPushNotification(invitation.owner.id, title: "Invitation Accepted", message: user.name + " just accepted your " + invitation.type + " invitation")
                                delete(id: invitation.id)
                            }
                        }
                    }
                } else if invitation.type == "refrigerator" {
                    YKNetworkManager.shared.updateAll("refrigerators", values: ["shareID": invitation.owner.id]) {
                        Messaging.sendPushNotification(invitation.owner.id, title: "Invitation Accepted", message: user.name + " just accepted your " + invitation.type + " invitation")
                        delete(id: invitation.id)
                    }
                } else {
                    print("Type not recognized")
                }
            case .deny:
                delete(id: invitation.id)
            }
        }

        public static func delete(id: String) {
            guard YKNetworkManager.shared.currentUser != nil else {
                return
            }

            let fstore = Firestore.firestore()
            fstore.collection("invitations").whereField("id", isEqualTo: id).getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Invitation/delete " + err.localizedDescription)
                    return
                }
                if let snap = snap {
                    let batch = fstore.batch()
                    snap.documents.forEach { doc in
                        batch.deleteDocument(doc.reference)
                    }
                    batch.commit { err in
                        if let err = err {
                            UserResponse.displayError(msg: err.localizedDescription)
                            return
                        }
                    }
                }
            }
        }
    }
}

public enum InvitationStatus {
    case accept
    case deny
}
