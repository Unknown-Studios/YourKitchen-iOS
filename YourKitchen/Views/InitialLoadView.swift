//
//  InitialLoadView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 08/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import Firebase

struct InitialLoadView: View {
    @State var loadedUser = false
    @State var loadedRecipes = false
    @State var loadedIngredients = false
    @State var loadedRefrigerator = false
    @State var user: YKUser?

    var body: some View {
        VStack {
            if loadedUser && loadedRecipes && loadedIngredients && loadedRefrigerator {
                LoginView(user: self.$user)
            } else {
                Image("Logo")
                    .resizable()
                    .frame(width: 150, height: 150)
                Text("YourKitchen")
                    .font(.title)
                ActivityIndicator(isAnimating: .constant(true), style: .large)
                if #available(iOS 14.0, *) {
                    ProgressView(value: self.progress)
                        .frame(width: 200)
                }
            }
        }.onAppear {
            self.loadNetwork()
            Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        }
    }
    
    var progress : Double {
        var tmpProgress = 0.0
        tmpProgress += loadedUser ? 0.25 : 0.0
        tmpProgress += loadedRecipes ? 0.25 : 0.0
        tmpProgress += loadedRefrigerator ? 0.25 : 0.0
        tmpProgress += loadedIngredients ? 0.25 : 0.0
        return tmpProgress
    }

    func loadNetwork() {
        YKNetworkManager.Users.get { (user) in
            print("Loaded user")
            self.loadedUser = true
            self.user = user
        }
        YKNetworkManager.Recipes.getAll { _ in
            print("Loaded Recipes")
            self.loadedRecipes = true
        }
        YKNetworkManager.Refrigerators.get { _ in
            print("Loaded refrigerator")
            self.loadedRefrigerator = true
        }
        YKNetworkManager.Ingredients.get { _ in
            print("Loaded ingredients")
            self.loadedIngredients = true
        }
    }
}

struct InitialLoadView_Previews: PreviewProvider {
    static var previews: some View {
        InitialLoadView()
    }
}
