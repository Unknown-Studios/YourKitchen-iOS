//
//  UserDetailView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ActionOver
import ASCollectionView
// import QGrid
import struct Kingfisher.DownsamplingImageProcessor
import struct Kingfisher.KFImage
import SwiftUI
import FirebaseAnalytics

struct UserDetailView: View {
    @State var user: YKUser
    @State var recipes = [Recipe]()
    
    //View
    @State var loading = false
    
    // Notifications
    @State var notifications = [YKNotification]()
    @State var showNotificationView = false

    // Select Profile Picture
    @State var showImageAction = false
    @State var showTakePhoto = false
    @State var showImagePicker = false
    @State var image: UIImage?

    init(user: YKUser) {
        self._user = State(wrappedValue: user)
    }

    var body: some View {
        Group {
            // LabelledDivider(label: "Recipes")
            /*ASCollectionView {
                ASCollectionViewSection(
                    id: 0,
                    data: [Recipe.none]
                ) // Only one item if the section is header. If we are in the recipes section go for the length of recipes
                    { _, _ in
                        UserHeaderView(user: self.$user)
                    }
                ASCollectionViewSection(
                    id: 1,
                    data: self.recipes
                ) // Only one item if the section is header. If we are in the recipes section go for the length of recipes
                    { item, _ in
                        UserRecipeRow(recipe: item)
                    }
            }
            .layout(self.layout(self.columnCount))
            .alwaysBounceVertical()
            .navigationBarTitle(Text(self.user.name), displayMode: .inline)*/
            LoadingView(title: "Loading user..", loading: self.$loading) {
                Group {
                    YKGrid(self.recipes, columns: 2, columnsInLandscape: 4, onRefresh: {
                        self.loading = true
                        self.refreshUserRecipes()
                    }, header: {
                        UserHeaderView(user: self.$user)
                    }) { (item) in
                        UserRecipeRow(recipe: item)
                    }
                }
            }.navigationBarTitle(Text(self.user.name), displayMode: .inline)
        }.sheet(isPresented: self.$showNotificationView) {
            NotificationView(notifications: self.$notifications)
        }.navigationBarItems(trailing: HStack {
            if isOwnProfile() {
                Button(action: {
                    self.showNotificationView = true
                }) {
                    BadgeText(badgeCount: .constant(self.$notifications.wrappedValue.count)) {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .imageScale(.large)
                            .padding(8)
                    }
                }
                self.settingButton
            }
        })
        .onDisappear(perform: {
            YKNetworkManager.Notifications.removeListener("ProfileView")
        })
        .onAppear {
            self.refreshUserRecipes()
            if self.isOwnProfile() {
                self.refreshNotifications()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: self.isOwnProfile() ? "Profile" : "User Detail",
                                            AnalyticsParameterScreenClass: UserDetailView.self])
        }
    }

    func title(_ section: Int) -> some View {
        VStack {
            if section == 1 {
                LabelledDivider(label: "Recipes")
            }
            EmptyView()
        }
    }

    var columnCount: Int {
        return UIDevice.current.userInterfaceIdiom == .phone ? 2 : 3
    }
    
    var settingButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gear")
                .font(.system(size: 20.0))
        }
        .padding()
    }
    
    /**
     If the profile is ours listen for new notifications.
     */
    func refreshNotifications() {
        guard isOwnProfile() else {
            return
        }
        YKNetworkManager.Notifications.getListener(id: "ProfileView") { notifications in
            self.notifications = notifications
        }
    }

    func isOwnProfile() -> Bool {
        self.user == YKNetworkManager.shared.currentUser
    }

    func refreshUserRecipes() {
        print("Reloading recipes")
        self.loading = true
        self.recipes.removeAll()
        YKNetworkManager.Users.getRecipesFromUser(user) { recipes in
            self.recipes = recipes
            self.loading = false
        }
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView(user: YKUser.none)
    }
}
