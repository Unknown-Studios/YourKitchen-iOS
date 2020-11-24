//
//  MainView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FASwiftUI
import Firebase
import SwiftUI
import UserNotifications

struct MainView: View {
    @State var actionState: Int? = 0
    private var badgePosition: CGFloat = 4
    private var tabsCount: CGFloat = 4

    init() {
        userId = AppDelegate.userID
        recipeId = AppDelegate.recipeID
        if AppDelegate.showMealplan {
            tabViewState = 3
        }
        // We have used them, so we can reset them.
        AppDelegate.userID = nil
        AppDelegate.recipeID = nil
        AppDelegate.showMealplan = false
    }

    //Deeplinking
    @State var recipeId: String?
    @State var recipe: Recipe?
    @State var userId: String?
    @State var notificationUser: YKUser?

    @State var tabViewState: Int = 0

    var body: some View {
        TabView(selection: self.$tabViewState) {
            NavigationView {
                RecipeView(tab: self.$tabViewState)
                NavigationLink(destination: RecipeDetailView(recipe: (self.recipe ?? Recipe.none)),
                               tag: 1,
                               selection: self.$actionState) {
                    EmptyView()
                }
                NavigationLink(destination: UserDetailView(user: self.notificationUser ?? YKUser.none),
                               tag: 2,
                               selection: self.$actionState) {
                    EmptyView()
                }
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                if self.tabViewState == 0 {
                    Image(systemName: "house.fill")
                } else {
                    Image(systemName: "house")
                }
                Text("Home")
            }.tag(0)
            ExploreView().tabItem {
                Image(systemName: "magnifyingglass")
                Text("Explore")
            }.tag(1)
            RefrigeratorView().tabItem {
                Image(systemName: "doc.plaintext")
                Text("Refrigerator")
            }.tag(2)
            MealPlanView().environmentObject(SocialMealplan(owner: YKUser.none, mealplan: Mealplan.none)).tabItem {
                Image(systemName: "calendar")
                Text("Meal Plan")
            }.tag(3)
            ProfileView(user: .constant(YKNetworkManager.shared.currentUser!))
                .tabItem {
                if self.tabViewState == 4 {
                    Image(systemName: "person.fill")
                } else {
                    Image(systemName: "person")
                }
                Text("Profile")
            }.tag(4)
        }.accentColor(AppConstants.Colors.YKColor)
        .onAppear {
            self.getRecipe()
            self.getUser()
            self.handleNotifications()
        }
    }

    func getUser() {
        if let userId = self.userId {
            YKNetworkManager.Users.get(userId) { user in
                print("Got user")
                self.notificationUser = user
                self.actionState = 2
                self.userId = nil // Resets
            }
        }
    }
    
    func handleNotifications() {
        guard YKNetworkManager.shared.currentUser != nil else { return }
        if (!CommandLine.arguments.contains("-uiTesting")) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
                    if let err = err {
                        UserResponse.displayError(msg: err.localizedDescription)
                        return
                    }
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    self.handleNotificationAccess()
                }
        }
    }
    
    func handleNotificationAccess() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func getRecipe() {
        if let recipeId = self.recipeId {
            YKNetworkManager.Recipes.get(id: recipeId) { recipe in
                print("Got recipe")
                self.recipe = recipe
                self.actionState = 1
                self.recipeId = nil // Resets
            }
        }
    }
}
