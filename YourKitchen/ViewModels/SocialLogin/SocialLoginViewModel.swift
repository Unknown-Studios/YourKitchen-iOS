//
//  SocialLoginModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FBSDKLoginKit
import Firebase
import GoogleSignIn
import SwiftUI

public enum LoginType {
    case facebook
    case google
    case apple
}

public class SocialLoginViewModel: NSObject, LoginButtonDelegate, GIDSignInDelegate {
    // Unhashed nonce.
    var currentNonce: String?
    let loginButton = FBLoginButton()

    override init() {
        super.init()
        loginButton.isHidden = true
        loginButton.delegate = self
        loginButton.permissions = ["email", "public_profile"]
        GIDSignIn.sharedInstance().delegate = self
    }

    public var completion: ((User?, String?) -> Void)?

    public func submitCredential(credential: AuthCredential, fullName: String = "") {
        print("Submitting credentials...")
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let authError = error as NSError
                UserResponse.displayError(msg: authError.localizedDescription)
                if let c = self.completion {
                    c(nil, error.localizedDescription)
                    self.completion = nil
                }
                return
            }
            if fullName != "" {
                let changeRequest = authResult!.user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                changeRequest.commitChanges { err in
                    if let err = err {
                        UserResponse.displayError(msg: err.localizedDescription)
                        if let c = self.completion {
                            c(nil, err.localizedDescription)
                            self.completion = nil
                            return
                        }
                    }
                    self.createUser(user: authResult!.user)
                }
            } else {
                self.createUser(user: authResult!.user)
            }
        }
    }

    public func createUser(user: User, completion: ((User?, String?) -> Void)? = nil) {
        if completion != nil {
            self.completion = completion
        }
        let fstore = Firestore.firestore()

        var userDoc = [String: Any]()
        userDoc["adConsent"] = UserDefaults.standard.bool(forKey: "adConsent")
        userDoc["privacyConsent"] = UserDefaults.standard.bool(forKey: "privacyConsent")

        print("Creating user: " + (user.email ?? ""))

        fstore.collection("users").document(user.uid).setData(userDoc, merge: true) { err in
            if let err = err {
                UserResponse.displayError(msg: err.localizedDescription)
                if let c = self.completion {
                    c(nil, err.localizedDescription)
                    self.completion = nil
                }
                return
            }
            if let c = self.completion {
                c(user, nil)
                self.completion = nil
            }
        }
    }

    public func testSignIn(completion _: @escaping (Bool) -> Void) {
        guard CommandLine.arguments.contains("-uiTesting") else {
            return
        }
        let fauth = Auth.auth()
        fauth.signIn(withEmail: "test@unknown-studios.com", password: "testtest") { result, error in
            if let error = error {
                let authError = error as NSError
                UserResponse.displayError(msg: authError.localizedDescription)
                if let c = self.completion {
                    c(nil, error.localizedDescription)
                    self.completion = nil
                }
                return
            }
            guard let result = result else { return }
            self.createUser(user: result.user)
        }
    }

    public func login(type: LoginType, completion: @escaping (User?, String?) -> Void) {
        if self.completion != nil {
            print("Login request")
            UserResponse.displayError(msg: "A login request is already in progress")
        }
        self.completion = completion
        switch type {
        case .facebook:
            loginButton.sendActions(for: .touchUpInside)
            print("Started Facebook sign in")
        case .google:
            GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.first?.rootViewController
            GIDSignIn.sharedInstance()?.signIn()
            print("Started Google sign in")
        case .apple:
            startSignInWithAppleFlow()
            print("Started Apple sign in")
        }
    }

    public func signOut(_ completion: @escaping () -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            YKNetworkManager.shared.sendMessageToWatch(message: ["sign-out": true])
            YKNetworkManager.Messaging.deleteDeviceToken()
            UserDefaults.standard.removeObject(forKey: "mealplanLast")
            UserDefaults.standard.removeObject(forKey: "likes")
            UIApplication.shared.applicationIconBadgeNumber = 0
            let loginManager = LoginManager()
            loginManager.logOut() // this is an instance function
            try firebaseAuth.signOut()
            YKNetworkManager.shared.currentUser = nil
            completion()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
