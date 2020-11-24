//
//  LicensesView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 05/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct LicensesView: View {
    var body: some View {
        Form {
            NavigationLink(destination: WebView(url: "https://fontawesome.com/license")
                .navigationBarTitle("Font Awesome", displayMode: .inline)) {
                Text("Font Awesome")
            }
        }.navigationBarTitle("Licenses")
    }
}

struct LicensesView_Previews: PreviewProvider {
    static var previews: some View {
        LicensesView()
    }
}
