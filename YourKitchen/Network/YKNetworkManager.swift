//
//  YKNetworkManager.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import WatchConnectivity

public class YKNetworkManager: NSObject, WCSessionDelegate {
    public func sessionDidBecomeInactive(_: WCSession) {}

    public func sessionDidDeactivate(_: WCSession) {}

    public func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error: Error?) {
        if let err = error {
            UserResponse.displayError(msg: err.localizedDescription)
        }
    }

    func sendMessageToWatch(message: [String: Any]) {
        if let session = session {
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }

    var session: WCSession?
    fileprivate static var _singleton: YKNetworkManager?
    public static var shared: YKNetworkManager {
        if _singleton == nil {
            _singleton = YKNetworkManager()
        }
        return _singleton!
    }

    private var _currentUser: YKUser?
    public var currentUser : YKUser? {
        get {
            if Auth.auth().currentUser == nil {
                return nil
            }
            return _currentUser
        }
        set {
            _currentUser = newValue
        }
    }

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
    }

    public func updateAll(_ collection: String, anotherUser: YKUser? = nil, values: [String: Any], _ completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = anotherUser?.id ?? user.uid

        let fstore = Firestore.firestore()
        fstore.collection(collection).whereField("ownerId", isEqualTo: uid).getDocuments { snap, err in
            if let err = err {
                UserResponse.displayError(msg: "YKNetworkManager/updateAll(" + collection + ") " + err.localizedDescription)
                return
            }
            if let snap = snap {
                let batch = fstore.batch()
                snap.documents.forEach { doc in
                    batch.updateData(values, forDocument: doc.reference)
                }
                batch.commit { err in
                    if let err = err {
                        UserResponse.displayError(msg: "YKNetworkManager/updateAll(" + collection + ") " + err.localizedDescription)
                        return
                    }
                    completion()
                }
            }
        }
    }
}

// Premium constant
public var premium: Bool {
    var premium = false
    if let user = YKNetworkManager.shared.currentUser, let userPremium = user.premium {
        premium = userPremium.isInTheFuture
    }
    return premium
}
