//
//  SocialLogin+Facebook.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit

/* Facebook login */
extension SocialLoginViewModel {
    public func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            UserResponse.displayError(msg: error.localizedDescription)
            if let c = self.completion {
                c(nil, error.localizedDescription)
                self.completion = nil
            }
            return
        }
        print("Getting accesstoken")
        guard let token = AccessToken.current else {
            if let c = self.completion {
                c(nil, "")
                self.completion = nil
            }
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
        submitCredential(credential: credential)
    }

    public func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

    }
}
