//
//  ContentView.swift
//  WatchOS Extension
//
//  Created by Markus Moltke on 01/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject var userSettings : UserSettings
    
    var body: some View {
        return VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50.0, height: 50.0)
                .clipped()
            if (self.userSettings.uid != nil) {
                NavigationLink(destination: ShoppingListView()) {
                    HStack {
                        Image(systemName: "doc.plaintext")
                        Text("Shopping List")
                        Spacer()
                    }
                }
                NavigationLink(destination: SettingsView().environmentObject(self.userSettings)) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                        Spacer()
                    }
                }
            } else {
                Text("You need to sign in on the iOS app, before you can continue")
                    .multilineTextAlignment(.center)
            }
        }.padding(.horizontal, 8)
    }
}

class UserSettings: ObservableObject {
    @Published var uid: String? {
        didSet {
            if (uid == nil) {
                UserDefaults.standard.removeObject(forKey: "main-account")
            } else {
                UserDefaults.standard.set(uid, forKey: "main-account")
            }
        }
    }
    
    init() {
        self.uid = UserDefaults.standard.object(forKey: "main-account") as? String
    }
}
