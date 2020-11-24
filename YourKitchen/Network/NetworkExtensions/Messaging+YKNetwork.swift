//
//  YKNetwork+Messaging.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import FirebaseFirestore
import Foundation

public extension YKNetworkManager {
    enum Messaging {
        public static func getDeviceTokens(_ userID: String? = nil, _ completion: @escaping ([NotificationToken]) -> Void) {
            let fstore = Firestore.firestore()
            let user = YKNetworkManager.shared.currentUser
            fstore.collection("users").document(userID ?? (user?.id) ?? "").getDocument { doc, err in
                if let err = err {
                    UserResponse.displayError(msg: "Messaging/getDeviceTokens " + err.localizedDescription)
                    return
                }
                if let doc = doc, let tokens = try? doc.data(as: [NotificationToken].self) {
                    completion(tokens)
                    return
                }
                completion([])
            }
        }

        public static func deleteDeviceToken() {
            guard let device = UIDevice.current.identifierForVendor else {
                return
            }
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            let fstore = Firestore.firestore()
            getDeviceTokens { tokens in
                let tmpTokens = tokens.filter {
                    $0.device != device.uuidString
                }
                fstore.collection("users").document(user.id).updateData(["deviceToken": tmpTokens])
            }
        }

        public static func updateDeviceToken(_ token: String) {
            guard let device = UIDevice.current.identifierForVendor else {
                return
            }
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }
            let fstore = Firestore.firestore()
            getDeviceTokens { tokens in
                var tmpTokens = tokens.filter {
                    $0.device != device.uuidString
                }
                tmpTokens.append(NotificationToken(device: device.uuidString, token: token))
                fstore.collection("users").document(user.id).updateData(["deviceToken": tmpTokens])
            }
        }

        public static func sendPushNotification(user: YKUser, title: String, message: String, data: [String: String]? = nil, mutable: Bool = false) {
            sendPushNotification(user.id, title: title, message: message, data: data, mutable: mutable)
        }

        public static func sendPushNotification(_ userID: String, title: String, message: String, data: [String: String]? = nil, mutable: Bool = false) {
            getDeviceTokens(userID) { tokens in
                sendMessage(tokens: tokens, title: title, body: message, data: data, mutable: mutable)
            }
        }

        fileprivate static func sendMessage(tokens: [NotificationToken], title: String, body: String, data: [String: String]? = nil, mutable: Bool = false) {
            for token in tokens {
                var paramString: [String: Any] = [
                    "token": token.token,
                    "title": title,
                    "body": body
                ]
                if data != nil, data!.count > 0 {
                    if let jsonData = try? JSONEncoder().encode(data) {
                        paramString["data"] = String(data: jsonData, encoding: .utf8)
                    }
                }
                if mutable {
                    paramString["mutable"] = 1
                }

                let url = URL(string: "https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/sendMessage")!
                AF.request(url, method: .post, parameters: paramString, encoding: JSONEncoding.default)
                    .validate(statusCode: 200 ..< 300)
                    .responseString { response in
                        switch response.result {
                        case let .success(value):
                            print(value)
                        case let .failure(err):
                            UserResponse.displayError(msg: err.localizedDescription)
                        }
                    }
            }
        }
    }
}
