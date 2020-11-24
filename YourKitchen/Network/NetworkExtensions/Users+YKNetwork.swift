//
//  YKNetwork+Users.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import WatchConnectivity
import WidgetKit

import FirebaseCrashlytics
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

public extension YKNetworkManager {
    enum Users {
        public static var cache = NSCache<NSString, AnyObject>()

        /**
         Used to fetch a user

         - Parameters:
            - userID: Define this to get a specific user (default value: nil)
            - cache: Whether or not to use the cache (default value: true)
            - completion: Callback
         */
        public static func get(_ userID: String? = nil, cache: Bool = true, _ completion: @escaping (YKUser?) -> Void) {
            let fstore = Firestore.firestore()
            if cache, userID == nil, let cacheUser = YKNetworkManager.shared.currentUser {
                completion(cacheUser)
                return
            }
            var UID = userID
            if userID == nil {
                guard let user = Auth.auth().currentUser else {
                    completion(nil)
                    return
                }
                UID = user.uid
            }
            guard let uid = UID else {
                print("User not found in fetch")
                return
            }
            fstore.collection("users").document(uid).getDocument { doc, err in
                if let err = err {
                    UserResponse.displayError(msg: "Users/get " + err.localizedDescription)
                    return
                }
                guard let doc = doc else { return }
                if (!doc.exists && uid == Auth.auth().currentUser?.uid) {
                    guard let user = Auth.auth().currentUser else {
                        print("User not found")
                        return
                    }
                    var ykUser = YKUser(id: user.uid, name: user.displayName ?? "", email: user.email ?? "", image: user.photoURL?.absoluteString ?? "", following: [])
                    ykUser.reference = fstore.collection("users").document(user.uid)
                    try? ykUser.reference!.setData(from: ykUser)
                    YKNetworkManager.shared.currentUser = ykUser
                    YKNetworkManager.shared.sendMessageToWatch(message: ["main-account": uid])

                    // Used to communicate with today view
                    UserDefaults.standard.set(ykUser.adConsent, forKey: "adConsent")
                    UserDefaults.standard.set(ykUser.privacyConsent, forKey: "privacyConsent")
                    UserDefaults(suiteName: "group.com.unknownstudios.yk")!.set(ykUser.id, forKey: "userID")

                    if ykUser.privacyConsent {
                        Crashlytics.crashlytics().setUserID(ykUser.id)
                    }

                    let data = Data(ykUser.id.utf8)
                    do {
                        try data.write(to: URL.sharedDataFileURL, options: .atomic)
                    } catch {
                        UserResponse.displayError(msg: error.localizedDescription)
                    }
                    print("Done")
                    completion(ykUser)
                } else if let ykUser = try? doc.data(as: YKUser.self) {
                    if let user = Auth.auth().currentUser,uid == user.uid {
                        YKNetworkManager.shared.currentUser = ykUser
                        YKNetworkManager.shared.sendMessageToWatch(message: ["main-account": uid])

                        // Used to communicate with today view
                        UserDefaults.standard.set(ykUser.adConsent, forKey: "adConsent")
                        UserDefaults.standard.set(ykUser.privacyConsent, forKey: "privacyConsent")
                        UserDefaults(suiteName: "group.com.unknownstudios.yk")!.set(ykUser.id, forKey: "userID")

                        if ykUser.privacyConsent {
                            Crashlytics.crashlytics().setUserID(ykUser.id)
                        }

                        let data = Data(ykUser.id.utf8)
                        do {
                            try data.write(to: URL.sharedDataFileURL, options: .atomic)
                        } catch {
                            UserResponse.displayError(msg: error.localizedDescription)
                        }
                    }
                    completion(ykUser)
                }
            }
        }

        /**
         Used to fetch all users

         - Parameters:
            - cache: Whether or not to use cache
            - completion: callback
         */
        public static func getAll(_ cache: Bool = true, completion: @escaping ([YKUser]) -> Void) {
            if cache {
                if let item = Users.cache.object(forKey: "users") as? [YKUser] {
                    return completion(item)
                }
            }
            let fstore = Firestore.firestore()
            fstore.collection("users").getDocuments { snap, err in
                if let err = err {
                    UserResponse.displayError(msg: "Users/getAll " + err.localizedDescription)
                    return
                }
                guard let snap = snap else { return }
                var users = [YKUser]()
                for doc in snap.documents {
                    if let ykUser = try? doc.data(as: YKUser.self) {
                        users.append(ykUser)
                    }
                }
                Users.cache.setObject(users as NSArray, forKey: "users")
                print("Fetched " + users.count.description + " users")
                completion(users)
            }
        }

        /**
         Get the recipes that a user has made in their career :)

         - Parameters:
            - user: The user to get the recipes from
            - completion: Callback
         */
        public static func getRecipesFromUser(_ user: YKUser, _ completion: @escaping ([Recipe]) -> Void) {
            YKNetworkManager.Recipes.getAll { recipes in
                completion(recipes.filter { $0.author.id == user.id })
            }
        }

        /**
         Used to update following state for a user.

         - Parameters:
            - followUser: The user we are either following or unfollowing
            - follow: Whether or not to follow or unfollow the user.
         */
        public static func updateFollowing(followUser: YKUser, follow: Bool, _ completion: @escaping (YKUser) -> Void) {
            guard YKNetworkManager.shared.currentUser != nil else {
                return
            }

            let fstore = Firestore.firestore()
            YKNetworkManager.Users.get(cache: false) { user in //We need to refresh user to be sure we have the latest
                guard var tmpUser = user else { return }
                if follow {
                    if !tmpUser.following.contains(followUser.id) {
                        tmpUser.following.append(followUser.id)
                    }
                } else {
                    tmpUser.following.removeAll(where: { $0 == followUser.id })
                }
                tmpUser.reference = fstore.collection("users").document(tmpUser.id)
                var tmpData = [String: Any]()
                tmpData["following"] = tmpUser.following
                tmpData["reference"] = tmpUser.reference
                if let doc = tmpUser.reference {
                    doc.updateData(tmpData) { err in
                        if let err = err {
                            UserResponse.displayError(msg: "Users/updateFollowing " + err.localizedDescription)
                            return
                        }
                        YKNetworkManager.shared.currentUser = tmpUser
                        if follow {
                            Messaging.sendPushNotification(user: followUser, title: "You got a new follower", message: followUser.name + " started following you", data: ["user": tmpUser.id])
                        }
                        completion(tmpUser)
                    }
                }
            }
        }

        /**
         Update profile picture for self
         - Parameters:
            - image: The profile picture to be set for the user
            - completion: The callback. (Download URL)
         */
        public static func updateImage(image: UIImage, _ completion: ((String) -> Void)? = nil) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            let storage = Storage.storage()
            let storageRef = storage.reference()

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            guard let imageData: Data = image.jpegData(compressionQuality: 0.75) else {
                return
            }

            let locRef = storageRef.child("users/" + user.id + ".jpg")
            locRef.putData(imageData, metadata: metadata) { _, err in
                if let err = err {
                    UserResponse.displayError(msg: err.localizedDescription)
                    return
                }
                locRef.downloadURL(completion: { (url: URL?, _: Error?) in
                    guard let downloadURL = url?.absoluteString else { return }
                    update(array: ["image": downloadURL]) {_ in
                        if let completion = completion {
                            completion(downloadURL)
                        }
                    }
                })
            }
        }

        /**
        Update the user document with the given values.
         - Parameters:
            - array: A dictionary of the items to update
         */
        public static func update(array: [String: Any], _ completion: ((YKUser) -> Void)? = nil) {
            guard let user = YKNetworkManager.shared.currentUser else {
                return
            }

            // Add the current timezone on each update
            var tmpArray = array
            var localTimeZoneIdentifier: String { TimeZone.current.identifier }
            tmpArray["timezone"] = localTimeZoneIdentifier

            let fstore = Firestore.firestore()
            fstore.collection("users").document(user.id).updateData(tmpArray) { err in
                if let err = err {
                    UserResponse.displayError(msg: "Users/update " + err.localizedDescription)
                    return
                }
                if let completion = completion {
                    get(cache: false) { (user) in
                        if let user = user {
                            completion(user)
                        }
                    }
                }
            }
        }

        /**
         Get the following array from a user as a [YKUser] array

         -  Parameters:
            - user: The user in question.
            - completion: Callback
         */
        public static func getFollowingForUser(_ user: YKUser, completion: @escaping ([YKUser]) -> Void) {
            get(user.id, cache: false) { newUser in
                guard let newUser = newUser else { return }
                self.getAll(false) { users in
                    let followingArray = users.filter {
                        newUser.following.contains($0.id)
                    }
                    completion(followingArray)
                }
            }
        }

        /**
         Get the people that are following this user.
         
         - Parameters:
            - user: The user to get this for
            - completion: callback from action, returns the people that are following this user.
         */
        public static func getFollowersForUser(_ user: YKUser, completion: @escaping ([YKUser]) -> Void) {
            getAll { users in
                let followersArray = users.filter {
                    $0.following.contains(user.id)
                }
                completion(followersArray)
            }
        }
    }
}
