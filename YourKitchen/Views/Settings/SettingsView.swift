//
//  SettingsView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import Combine
import Firebase
import struct Kingfisher.KFImage
import class Kingfisher.KingfisherManager
import SwiftUI

struct SettingsView: View {
    var socialModel = SocialLoginViewModel()
    @State var logoutAlertShown = false
    @State var deleteUserAlertShown = false
    @State var showingLogin = false
    @State var showingPremium = false
    @State var loading = false

    @ViewBuilder var body: some View {
        if (YKNetworkManager.shared.currentUser == nil) {
            EmptyView()
        }
        LoadingView(title: nil, loading: self.$loading) {
            Form {
                Section {
                    Button(action: {
                        self.logoutAlertShown = true
                    }) {
                        Group {
                            HStack {
                                KFImage(YKNetworkManager.shared.currentUser?.image.url)
                                    .placeholder({
                                        Image("UserImage")
                                    })
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 60.0, height: 60.0)
                                VStack(alignment: .leading) {
                                    Text(YKNetworkManager.shared.currentUser?.name ?? "")
                                        .font(.system(size: 18.0))
                                        .bold()
                                    Text(YKNetworkManager.shared.currentUser?.email ?? "")
                                        .font(.system(size: 14.0))
                                        .foregroundColor(Color.secondary)
                                    Spacer()
                                }
                            }
                        }
                    }.buttonStyle(PlainButtonStyle())
                    .frame(height: 75.0)
                    Button(premium ? "Manage subscription" : "Get Premium") {
                        if premium {
                            UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
                        } else {
                            showingPremium = true
                        }
                    }.sheet(isPresented: self.$showingPremium) {
                        GetPremiumView()
                    }
                }
                Section(header: Text("General")) {
                    NavigationLink(destination: EditAllergenesView()) {
                        Text("Allergenes")
                    }
                    NavigationLink(destination: EnterTVCodeView()) {
                        Text("Enter code")
                    }
                }
                Section(header: Text("Feedback")) {
                    Button(action: {
                        if let url = AppConstants.URL.trelloIOS.url {
                            UIApplication.shared.open(url)
                        }
                    }, label: {
                        Text("Trello")
                            .foregroundColor(Color.primary)
                    })
                    NavigationLink(destination: SendFeedbackView()) {
                        Text("Send Feedback")
                    }
                    NavigationLink(destination: ReportIssueView()) {
                        Text("Report issue")
                    }
                }
                Section(header: Text("Data")) {
                    NavigationLink(destination: AdDetailView()) {
                        Text("Ads")
                    }
                    NavigationLink(destination: WebView(url: AppConstants.URL.privacyPolicy).navigationBarTitle("Privacy Policy", displayMode: .inline)) {
                        Text("Privacy Policy")
                    }
                }
                Section(header: Text("About")) {
                    NavigationLink(destination: WebView(url: AppConstants.URL.termsPolicy).navigationBarTitle("Terms & Conditions", displayMode: .inline)) {
                        Text("Terms & Conditions")
                    }
                    NavigationLink(destination: LicensesView()) {
                        Text("Licenses")
                    }
                    Button(action: {
                        KingfisherManager.shared.cache.clearMemoryCache()
                        KingfisherManager.shared.cache.clearDiskCache()
                    }) {
                        Text("Clear Cache")
                    }
                    Button(action: {
                        self.deleteUserAlertShown = true
                    }) {
                        Text("Delete User")
                            .foregroundColor(Color.red)
                    }.alert(isPresented: self.$deleteUserAlertShown, content: { () -> Alert in
                        Alert(title: Text("Delete User?"), message: Text("Are you sure you want to delete your user?"), primaryButton: .default(Text("No"), action: {
                            self.deleteUserAlertShown = false
                        }), secondaryButton: .destructive(Text("Yes"), action: {
                            self.deleteUser()
                        }))
                    })
                    Button(action: {
                        self.logoutAlertShown = true
                    }) {
                        Text("Sign out")
                            .foregroundColor(Color.red)
                    }
                }
            }
            .alert(isPresented: self.$logoutAlertShown) { () -> Alert in
                Alert(title: Text("Logout?"), message: Text("Are you sure you want to sign out?"), primaryButton: .default(Text("No"), action: {
                    self.logoutAlertShown = false
                }), secondaryButton: .destructive(Text("Yes"), action: {
                    self.socialModel.signOut {
                        YKNetworkManager.Notifications.removeListener("ProfileView")
                        print("Signed out")
                    }
                }))
            }
        }
        .navigationBarTitle("Settings")
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "Settings",
                                            AnalyticsParameterScreenClass: SettingsView.self])
        }
    }

    func deleteUser() {
        self.loading = true
        guard let user = Auth.auth().currentUser else { return }
        AF.session.configuration.timeoutIntervalForRequest = 120

        AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/deleteUser?id=" + user.uid)
            .validate(statusCode: 200 ..< 300)
            .responseString { response in
                switch response.result {
                case let .success(result):
                    print(result)
                    self.socialModel.signOut {
                        print("Deleted user")
                    }
                case let .failure(err):
                    print(err.localizedDescription)
                }
                self.loading = false
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
