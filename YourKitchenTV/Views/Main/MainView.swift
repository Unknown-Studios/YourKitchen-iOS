//
//  ContentView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 19/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var selection: Int = 0
    @State var hideNavigationBar = false

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: self.$selection) {
                    ExploreView(hideNavigationBar: self.$hideNavigationBar)
                        .onAppear {
                            self.hideNavigationBar = true
                        }
                        .tabItem {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Explore")
                            }
                        }
                        .tag(0)

                    MealplanView(hideNavigationBar: self.$hideNavigationBar)
                        .onAppear {
                            self.hideNavigationBar = true
                        }
                        .tabItem {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Meal Plan")
                            }
                        }
                        .tag(1)

                    SettingsView(hideNavigationBar: self.$hideNavigationBar)
                        .onAppear {
                            self.hideNavigationBar = true
                        }
                        .tabItem {
                            HStack {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                        }
                        .tag(2)
                }
            }
        }
        .onAppear {
            self.hideNavigationBar = true
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
