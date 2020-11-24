//
//  MealPlanView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI
import FirebaseAnalytics
import WidgetKit
import SwiftUIRefresh

struct MealPlanView: View {
    @EnvironmentObject var currentMealplan: SocialMealplan
    @State fileprivate var mealplans = [SocialMealplan]()
    
    //State
    @State var refreshed = false
    @State var selectedMealplan: Int = 0
    @State var selectedPersons: Int = YKNetworkManager.shared.currentUser?.defaultPersons ?? 1
    
    //View
    @State var showPicker = false
    @State var showingLogin = false
    @State var loading = false

    var viewModel = MealplanViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if self.mealplans.count > 1 {  //If we have more than our own mealplan
                    Section(header: Text("Selected Meal Plan")) {
                        Picker(selection: self.$currentMealplan.mealplan.onChange({ (mealplan) in
                            UserDefaults.standard.setValue(mealplan.ownerId, forKey: "mealplanLast")
                        }), label: Text("")) {
                            ForEach(self.mealplans) { (mealplan) in
                                HStack {
                                    KFImage(mealplan.owner.image.url)
                                        .resizable()
                                        .frame(width: 40.0, height: 40.0)
                                        .clipShape(Circle())
                                    VStack {
                                        HStack {
                                            Text(mealplan.owner.name)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(mealplan.owner.email)
                                                .foregroundColor(Color.secondary)
                                                .font(.system(size: 15.0))
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }.tag(mealplan)
                                .padding(8)
                            }.navigationBarTitle("Select Meal Plan")
                        }
                    }
                }
                Form {
                    Section(header: Text("Meal Plan")) {
                        Picker("Persons", selection: self.$selectedPersons.onChange({ value in
                            YKNetworkManager.Users.update(array: ["defaultPersons": value])
                        })) {
                            ForEach(1..<20, id: \.self) { num in
                                Text(num.description + (num == 1 ? " Person" : " Persons"))
                            }.navigationBarTitle("Selected persons")
                        }
                        ForEach(self.currentMealplan.mealplan.meals, id: \.self) { (meal) in
                            if meal.recipe.id == "none" {
                                NavigationLink(destination: SelectRecipeView(completion: self.updatedMealplan, date: meal.date)) {
                                    MealplanRow(meal: .constant(meal))
                                }
                            } else {
                                NavigationLink(destination: RecipeDetailView(recipe: meal.recipe, weekday: meal.date, completion: self.updatedMealplan)) {
                                    MealplanRow(meal: .constant(meal))
                                }
                            }
                        }
                    }
                }.pullToRefresh(isShowing: self.$loading) {
                    self.refreshMealplan()
                }
            }.onAppear {
                self.refreshMealplan()
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "Meal Plan View",
                                                AnalyticsParameterScreenClass: MealPlanView.self])
            }.navigationBarTitle(self.currentTitle)
            .onDisappear {
                self.mealplans.removeAll()
            }
            .navigationBarItems(trailing: NavigationLink(destination: ShareMealplanView(), label: {
                Image(systemName: "person.crop.circle.badge.plus")
                    .imageScale(.large)
                    .padding()
            }))
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    var currentTitle: String {
        let owner = self.currentMealplan.owner.id
        if owner == YKNetworkManager.shared.currentUser!.id || owner == "none" {
            return NSLocalizedString("Your", comment: "") + " " + NSLocalizedString("Meal Plan", comment: "")
        } else {
            return self.currentMealplan.owner.name + "s " + NSLocalizedString("Meal Plan", comment: "")
        }
    }

    func updatedMealplan(date: Date, recipe: Recipe) {
        print("Updating mealplan: " + date.description)
        let tmpMealplan = self.currentMealplan.mealplan
        tmpMealplan[date] = recipe

        self.currentMealplan.mealplan = tmpMealplan

        YKNetworkManager.Mealplans.update(tmpMealplan) { _ in
            self.refreshMealplan()
        }
    }

    func refreshMealplan() {
        YKNetworkManager.Mealplans.get(cache: false) { mealplans in
            // Get updated user from server
            let user = YKNetworkManager.shared.currentUser!
            if mealplans.count > 0 {
                let rightMealplan = mealplans[0]
                if self.currentMealplan.owner == YKUser.none || self.currentMealplan.owner == user { //If the variable is not set or the owner is the client, maintain the mealplan.
                    self.viewModel.maintainMealplan(mealplan: rightMealplan) { mealplan in
                        self.currentMealplan.mealplan = mealplan
                        
                        if #available(iOS 14.0, *) {
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        self.loading = false
                    }
                } else {
                    self.loading = false
                }

                // Get users
                YKNetworkManager.Users.getAll { users in
                    var tmpMealplans = [SocialMealplan]()
                    for idx in 0 ..< mealplans.count {
                        let item = mealplans[idx]
                        if let owner = users.filter({ $0.id == item.ownerId }).first {
                            tmpMealplans.append(SocialMealplan(owner: owner, mealplan: item))
                            // Restore state
                            if let last = UserDefaults.standard.string(forKey: "mealplanLast") {
                                if owner.id == last {
                                    self.selectedMealplan = idx
                                }
                            }
                        }
                    }
                    self.mealplans = tmpMealplans
                }
            } else {
                print("No meaplans loaded")
            }
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanView()
    }
}
