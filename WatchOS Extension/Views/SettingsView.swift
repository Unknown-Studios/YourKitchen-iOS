//
//  SettingsView.swift
//  WatchOS Extension
//
//  Created by Markus Moltke on 01/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import struct Kingfisher.KFImage
import SwiftUI

struct SettingsView: View {
    @State var name = ""
    @State var image = ""
    @State var email = ""

    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            KFImage(self.image.url)
                .placeholder {
                    Image("UserImage")
                }.resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(30)
                .aspectRatio(contentMode: .fill)
            VStack {
                Text(self.name)
                    .font(.headline)
                Text(self.email)
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
            Button(action: {
                self.userSettings.uid = nil
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Sign out")
            }.padding(.horizontal, 8)
        }.frame(minWidth: 0, maxWidth: .infinity)
            .onAppear {
                self.getUser()
            }
    }

    func getUser() {
        guard let userID = UserDefaults.standard.string(forKey: "main-account") else { return }
        AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/getUser?userID=" + userID)
            .validate(statusCode: 200 ..< 300)
            .responseJSON { response in
                switch response.result {
                case let .success(userJSON):
                    if let json = userJSON as? [String: String] {
                        self.name = json["name"] ?? ""
                        self.image = json["image"] ?? ""
                        self.email = json["email"] ?? ""
                    }
                case let .failure(err):
                    print(err.localizedDescription)
                }
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
