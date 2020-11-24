//
//  RefrigeratorView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 28/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ActionOver
import FASwiftUI
import SwiftUI
import FirebaseAnalytics

struct RefrigeratorView: View {
    @State var refrigerator = Refrigerator.none
    @State var shoppingList = ShoppingList.none
    @State var selectShopping = [Ingredient: Bool]()
    @State var isHost = false
    @State var storedIngredients = [Ingredient]()
    @State var storedRecipes = [Recipe]()

    @State var presentAction = false
    @State var isEditing = false
    @State var presentShare = false
    @State var presentScan = false
    @State var selectedPage: RefrigeratorPage = .refrigerator

    @State var oldIngredient: Ingredient = Ingredient.none
    @State var currentTitle = ""

    var body: some View {
        return NavigationView {
            VStack {
                Group {
                    NavigationLink(destination: ShareRefrigeratorView(isHost: self.$isHost), isActive: self.$presentShare) {
                        EmptyView()
                    }
                    /*NavigationLink(destination: ReceiptScannerView(), isActive: self.$presentScan) {
                        EmptyView()
                    }*/
                    Picker(selection: self.$selectedPage, label: Text("Selected page")) {
                        ForEach(RefrigeratorPage.allCases, id: \.name) { (item) in
                            Text(NSLocalizedString(item.prettyName, comment: "")).tag(item)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    self.mainView()
                }.environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
                .navigationBarTitle(self.currentTitle + (self.selectedPage == .refrigerator ?  NSLocalizedString("Refrigerator", comment: "") : NSLocalizedString("Shopping List", comment: "")))
                .navigationBarItems(trailing: Button(action: {
                    self.presentAction = true
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                        .padding()
                })).actionOver(presented: self.$presentAction,
                title: "Action",
                message: nil,
                buttons: [
                    .init(title: NSLocalizedString("Edit", comment: ""), type: .normal, action: {
                    self.isEditing = !self.isEditing
                  }),
                  //Check if storebox is possible first.
                  /*.init(title: "Scan Receipt", type: .normal, action: {
                    self.presentScan = true
                  }),*/
                    .init(title: NSLocalizedString("Share Refrigerator", comment: ""), type: .normal, action: {
                    self.presentShare = true
                  }),
                  .init(title: nil, type: .cancel, action: nil)],
                ipadAndMacConfiguration: self.ipadMacConfig)
            }
        }.onAppear {
            self.refreshRefrigerator()
            self.refreshStoredIngredients()
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "Refrigerator",
                                            AnalyticsParameterScreenClass: RefrigeratorView.self])
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder func mainView() -> some View {
        if self.selectedPage == .refrigerator {
            RefrigeratorTabView(refrigerator: self.$refrigerator, shoppingList: self.$shoppingList, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes, updateRefrigerator: self.updateRefrigerator)
        } else {
            ShoppingListView(refrigerator: self.$refrigerator, shoppingList: self.$shoppingList, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes, updateRefrigerator: self.updateRefrigerator)
        }
    }

    func updateShoppingList() {
        YKNetworkManager.ShoppingLists.update(shoppingList: shoppingList)
    }

    public var ipadMacConfig = {
        IpadAndMacConfiguration(anchor: nil, arrowEdge: nil)
    }()

    func deleteIngredient(at offsets: IndexSet) {
        self.refrigerator.ingredients.remove(atOffsets: offsets)
        self.updateRefrigerator()
    }

    func getIngredient(_ key: Int) -> Ingredient {
        let arr = Array(self.refrigerator.ingredients)
        return arr[key]
    }

    func updateRefrigerator() {
        YKNetworkManager.Refrigerators.update(refrigerator: self.refrigerator) {
            self.refreshRefrigerator()
        }
    }

    func refreshStoredIngredients() {
        YKNetworkManager.Ingredients.get { ingredients in
            self.storedIngredients = ingredients
        }
        YKNetworkManager.Recipes.getAll { (recipes) in
            self.storedRecipes = recipes
        }
    }

    func refreshRefrigerator() {
        YKNetworkManager.Refrigerators.add { _ in
            // Callback will only be called if there was a need to add a refrigerator (First time)
            self.refreshRefrigerator()
        }
        YKNetworkManager.Refrigerators.get(cache: false) { refrigerator in
            if let tmpRefrigerator = refrigerator {
                for item in tmpRefrigerator.ingredients {
                    let similar = tmpRefrigerator.ingredients.filter({ $0 == item })
                    if similar.count > 1 { //If there is more than one of this item
                        let first = similar.first!
                        first.amount = 0.0
                        for sim in similar {
                            first.amount += sim.amount
                        }
                        tmpRefrigerator.ingredients.removeAll(where: { $0 == first }) // Remove all similar ingredients
                        tmpRefrigerator.ingredients.append(first) // Add ingredient with new amount
                    }
                }
                self.refrigerator = tmpRefrigerator
                if tmpRefrigerator.ownerId == YKNetworkManager.shared.currentUser?.id {
                    self.currentTitle = NSLocalizedString("Your", comment: "") + " "
                    self.isHost = true
                } else {
                    YKNetworkManager.Users.get(tmpRefrigerator.ownerId) { user in
                        guard let user = user else { return }
                        self.currentTitle = user.firstName + "s "
                    }
                }
                YKNetworkManager.ShoppingLists.get(tmpRefrigerator.ownerId) { shoppingList in
                    if let shoppingList = shoppingList {
                        self.shoppingList = shoppingList
                    } else if let user = YKNetworkManager.shared.currentUser {
                        YKNetworkManager.ShoppingLists.update(shoppingList: ShoppingList(ownerId: user.id))
                    }
                }
                YKNetworkManager.Refrigerators.update(refrigerator: tmpRefrigerator)
            }
        }
    }
}

public enum RefrigeratorPage: CaseIterable {
    case refrigerator
    case shoppingList

    var prettyName: String {
        switch self {
        case .refrigerator: return "Refrigerator"
        case .shoppingList: return "Shopping List"
        }
    }

    var name: String {
        "\(self)".uppercased()
    }
}
