//
//  TestView.swift
//  YourKitchenTV
//
//  Created by Markus Moltke on 21/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct TestView: View {
    
    @State var selection : Int = 0
    @State var hideNavigationBar : Bool
    
    var body: some View {
        NavigationView {
            TabView(selection: self.$selection) {
                ExpView(hideNavigationBar: self.$hideNavigationBar)
                .tabItem {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Explore")
                    }
                }
                .tag(0)
            }
        }
    }
}

struct ExpView: View {
    
    @Binding var hideNavigationBar : Bool
    
    var body: some View {
        NavigationLink(destination: DetailView(title: "Hey")) {
            Text("Detail")
        }.navigationBarTitle("")
        .navigationBarHidden(self.hideNavigationBar)
        .onAppear {
            self.hideNavigationBar = true
        }
    }
}

struct DetailView: View {
    var title : String
    var body: some View {
        VStack {
            Text(title)
        }
    }
}
