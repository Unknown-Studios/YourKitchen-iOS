//
//  LoginView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 20/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct LoginView<Content : View>: View {
    
    var content : () -> Content
    @State var user : User?
    
    var body: some View {
        VStack {
            if (self.user == nil) {
                LoginActionView(user: self.$user)
            } else {
                self.content()
            }
        }.onAppear {
            self.listenForUser()
        }
    }
    
    func listenForUser() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("User: " + (self.user != nil).description)
            self.user = user
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView {
            Text("Hey")
        }
    }
}
