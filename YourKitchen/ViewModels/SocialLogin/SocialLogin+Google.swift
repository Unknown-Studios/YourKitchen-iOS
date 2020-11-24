//
//  SocialLogin+Google.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

/* Google login */
extension SocialLoginViewModel {

    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            UserResponse.displayError(msg: error.localizedDescription)
            if let c = self.completion {
                c(nil, error.localizedDescription)
                self.completion = nil
            }
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        submitCredential(credential: credential)
    }

    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            UserResponse.displayError(msg: error.localizedDescription)
            if let c = self.completion {
                c(nil, error.localizedDescription)
                self.completion = nil
            }
            return
        }
    }
}
