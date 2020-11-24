//
//  LoginActionView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 20/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct LoginActionView: View {
    @Binding var user: User?
    @State var listener: ListenerRegistration?

    // Alert
    @State var alertText: String = ""
    @State var alertPresented = false

    @Environment(\.colorScheme) var colorScheme

    @State var code = Int.random(in: 100_000 ..< 999_999).description

    var body: some View {
        VStack {
            Text("Login")
                .font(.title)
            Text("Enter the following code on the app or on the website.")
                .foregroundColor(Color.secondary)
            HStack {
                Text(self.code)
                    .font(.largeTitle)
                    .foregroundColor(Color.primary)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10.0)
                        .fill(colorScheme == .light ? Color.white.opacity(0.5) : Color.black.opacity(0.5)))
                    .padding()
            }
        }.alert(isPresented: self.$alertPresented) { () -> Alert in
            Alert(title: Text("Message"), message: Text(self.alertText), dismissButton: .cancel(Text("Okay")))
        }.onDisappear {
            if let listener = self.listener {
                listener.remove()
            }
        }.onAppear {
            self.startListener()
        }
    }

    func startListener() {
        let fstore = Firestore.firestore()

        let token = Token(code: code)
        var tmpToken = [String: Any]()
        tmpToken["id"] = token.id
        tmpToken["ownerEmail"] = token.ownerEmail
        tmpToken["code"] = token.code
        tmpToken["device"] = token.device

        // Remove listener if it already exists
        if let listener = self.listener {
            listener.remove()
        }
        guard let device = token.device else { return }
        fstore.collection("tokens").whereField("device", isEqualTo: device).getDocuments { snap, err in
            if let err = err {
                UserResponse.displayError(msg: err.localizedDescription)
                return
            }
            guard let snap = snap else { return }
            if snap.count > 0 {
                let data = snap.documents[0].data()
                if let code = data["code"] as? String, code != "" {
                    self.code = code
                } else {
                    snap.documents.forEach { doc in
                        doc.reference.updateData(tmpToken)
                    }
                }
            } else {
                fstore.collection("tokens").addDocument(data: tmpToken)
            }
            self.listener = fstore.collection("tokens").whereField("code", isEqualTo: self.code).addSnapshotListener { snap, err in
                if let err = err {
                    self.displayMessage(err.localizedDescription)
                    return
                }

                // Handle actionCode
                guard let snap = snap else {
                    return
                }
                snap.documents.forEach { doc in
                    if let token = try? doc.data(as: Token.self) {
                        if let actionLink = token.actionLink, let email = token.ownerEmail, let device = token.device { // We need to have a token with a actioncode
                            guard device == UIDevice.current.identifierForVendor?.uuidString else { return }
                            Auth.auth().signIn(withEmail: email, link: actionLink) { authResult, err in
                                if let error = err {
                                    let authError = error as NSError
                                    self.displayMessage(authError.localizedDescription)
                                    return
                                }
                                // No need to create user, as this action requires an account.

                                if let result = authResult {
                                    print("Signed in")
                                    self.user = result.user
                                    // Cleanup
                                    doc.reference.delete { err in
                                        if let err = err {
                                            print(err.localizedDescription)
                                            return
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func displayMessage(_ msg: String) {
        alertText = msg
        alertPresented = true
    }
}

struct Token: Identifiable, Codable {
    var id = UUID().uuidString
    var ownerEmail: String?
    var actionLink: String?
    var code: String
    var device = UIDevice.current.identifierForVendor?.uuidString
}
