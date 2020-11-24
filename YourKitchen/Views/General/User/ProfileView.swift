//
//  ProfileView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @Binding var user: YKUser

    var body: some View {
        NavigationView {
            UserDetailView(user: self.user)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
