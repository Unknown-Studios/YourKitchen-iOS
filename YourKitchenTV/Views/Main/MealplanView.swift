//
//  FeedView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 19/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

struct MealplanView: View {
    @ObservedObject var mealplanWrapper = MealplanWrapper(SocialMealplan(owner: YKUser.none, mealplan: Mealplan(ownerId: "", meals: [])))

    @State var selectedMealplan: Int = 0
    @State fileprivate var mealplans = [SocialMealplan]()

    @Binding var hideNavigationBar: Bool

    var viewModel = MealplanViewModel()

    var body: some View {
        LoginView {
            List {
                if self.mealplans.count > 1 { // If we have more than our own mealplan
                    Section(header: Text("Selected Meal Plan")) {
                        Picker(selection: self.$mealplanWrapper.mealplan.onChange { mealplan in
                            UserDefaults.standard.setValue(mealplan.owner.id, forKey: "mealplanLast")
                        }, label: Text("")) {
                            ForEach(self.mealplans) { mealplan in
                                Text(mealplan.owner.email)
                                    .tag(mealplan)
                                    .padding(8)
                            }
                        }
                    }
                }
                Section(header: Text("Meal Plan")) {
                    ForEach(self.mealplanWrapper.mealplan.mealplan.meals.indices, id: \.self) { index in
                        self.mealplanRow(meal: self.getItem(index).wrappedValue)
                    }
                }
            }
            .navigationBarTitle("Meal Plan")
            .navigationBarHidden(self.hideNavigationBar)
            .onAppear {
                self.hideNavigationBar = true
                self.refreshMealplans()
            }
        }.navigationBarTitle("Meal Plan")
            .navigationBarHidden(self.hideNavigationBar)
            .onAppear {
                self.hideNavigationBar = true
            }
    }

    func getItem(_ index: Int) -> (Binding<Meal>) {
        let item = self.$mealplanWrapper.mealplan.mealplan.meals[index]
        return item
    }

    @ViewBuilder func mealplanRow(meal: Meal) -> some View {
        if meal.id == "none" {
            NavigationLink(destination: SelectRecipeView(completion: self.updatedMealplan, date: meal.date)) {
                MealplanRow(date: meal.date,
                            recipe: meal.recipe)
            }
        } else {
            NavigationLink(destination: RecipeDetailView(recipe: meal.recipe)) {
                MealplanRow(date: meal.date,
                            recipe: meal.recipe)
            }
        }
    }

    func updatedMealplan(date: Date, recipe: Recipe) {
        var tmpMealplan = self.mealplanWrapper.mealplan.mealplan
        tmpMealplan[date] = recipe

        YKNetworkManager.Mealplans.update(tmpMealplan) { mealplan in
            YKNetworkManager.Users.get { user in
                self.mealplanWrapper.mealplan = SocialMealplan(owner: user, mealplan: mealplan)
            }
        }
    }

    func refreshMealplans() {
        YKNetworkManager.Mealplans.get(cache: false) { mealplans in
            YKNetworkManager.Users.getAll { users in
                if let user = users.filter({ $0 == YKNetworkManager.shared.currentUser }).first {
                    self.viewModel.maintainMealplan(mealplan: mealplans[0]) { mealplan in
                        if self.mealplanWrapper.mealplan.owner == YKUser.none {
                            self.mealplanWrapper.mealplan = SocialMealplan(owner: user, mealplan: mealplan)
                        }
                    }
                }
                var tmpMealplans = [SocialMealplan]()
                for idx in 0 ..< mealplans.count {
                    let item = mealplans[idx]
                    if let owner = users.filter({ $0.id == item.ownerId }).first {
                        let sMealplan = SocialMealplan(owner: owner, mealplan: item)
                        tmpMealplans.append(sMealplan)
                        // Restore state
                        if let last = UserDefaults.standard.string(forKey: "mealplanLast") {
                            if owner.id == last {
                                self.mealplanWrapper.mealplan = sMealplan
                            }
                        } else if idx == 0 {
                            self.mealplanWrapper.mealplan = sMealplan
                        }
                    }
                }
                print("Fetched mealplan")
                self.mealplans = tmpMealplans
            }
        }
    }
}

struct MealplanView_Previews: PreviewProvider {
    static var previews: some View {
        MealplanView(hideNavigationBar: .constant(true))
    }
}
