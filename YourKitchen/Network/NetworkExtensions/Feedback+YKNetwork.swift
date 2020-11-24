//
//  YKNetwork+Feedback.swift
//  YourKitchen
//
//  Created by Markus Moltke on 14/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import FirebaseAuth
import Foundation

public extension YKNetworkManager {
    enum Feedback {
        public static func sendFeedback(_ text: String, anonymize: Bool, _ completion: @escaping () -> Void) {
            var payload: [String: String]!

            if anonymize || Auth.auth().currentUser == nil {
                payload = [
                    "text": text
                ]
            } else if let user = Auth.auth().currentUser {
                payload = [
                    "text": "<https://console.firebase.google.com/u/0/project/yourkitchen-1e9e1/database/firestore/data~2Fusers~2F" + user.uid + "|User> \n" + text
                ]
            }

            AF.request("https://hooks.slack.com/services/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", method: .post, parameters: payload, encoding: JSONEncoding.default)
                .validate(statusCode: 200 ..< 300)
                .responseString { result in
                    switch result.result {
                    case let .success(res):
                        print(res.description)
                        completion()
                    case let .failure(err):
                        UserResponse.displayError(msg: err.localizedDescription)
                    }
                }
        }

        public static func sendIssue(_ text: String, anonymize: Bool, _ completion: @escaping () -> Void) {
            var issuetext = ""
            var userID = ""
            if anonymize || Auth.auth().currentUser == nil {
                issuetext = text
            } else if let user = Auth.auth().currentUser {
                issuetext = text
                userID = user.uid
            }

            AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/submitIssue?text=" + issuetext.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + (userID != "" ? "&userID=" + userID : ""))
                .validate(statusCode: 200 ..< 300)
                .responseString { result in
                    switch result.result {
                    case let .success(res):
                        print(res.description)
                        completion()
                    case let .failure(err):
                        UserResponse.displayError(msg: "Feedback/sendIssue " + err.localizedDescription)
                    }
                }
        }
    }
}
