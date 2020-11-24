//
//  SettingsView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 19/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseAuth
import struct Kingfisher.KFImage
import SwiftUI

struct SettingsView: View {
    @State var user = YKUser.none
    @State var presentSignout = false
    @Binding var hideNavigationBar: Bool
    var socialLoginViewModel = SocialLoginViewModel()

    var body: some View {
        LoginView {
            VStack {
                VStack {
                    KFImage(self.user.image.url, options: [
                        .transition(.fade(0.3))
                    ]).resizable()
                        .frame(width: 250.0, height: 250.0)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(125)
                        .padding(50)
                    Text(self.user.name)
                        .font(.title)
                    Text(self.user.email)
                        .font(.system(size: 50))
                        .foregroundColor(Color.secondary)

                    Spacer()
                }
                Button(action: {
                    // Sign out present
                    self.presentSignout = true
                }) {
                    Text("Sign out")
                }
            }
            .onAppear {
                self.refreshUser()
            }.alert(isPresented: self.$presentSignout) {
                Alert(title: Text("Sign out?"), message: Text("Are you sure you want to sign out?"), primaryButton: .destructive(Text("Yes"), action: {
                    socialLoginViewModel.signOut()
                }), secondaryButton: .cancel(Text("No")))
            }
        }.navigationBarTitle("Settings")
            .navigationBarHidden(self.hideNavigationBar)
            .onAppear {
                self.hideNavigationBar = true
            }
    }

    func listenForUser() {
        Auth.auth().addStateDidChangeListener { _, user in
            print("User " + (user == nil).description)
            self.refreshUser()
        }
    }

    func refreshUser() {
        YKNetworkManager.Users.get { user in
            self.user = user
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(hideNavigationBar: .constant(true))
    }
}
