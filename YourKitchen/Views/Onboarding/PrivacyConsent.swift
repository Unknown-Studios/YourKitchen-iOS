//
//  PrivacyConsent.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct PrivacyConsent: View {
    @Binding var accepted: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.white)
                Text("We care about your privacy and data security.")
                    .foregroundColor(Color.white)
                Text("aboutPrivacyPolicy")
                    .foregroundColor(Color.white)
                Button(action: {
                    if let privacyURL = AppConstants.URL.privacyPolicy.url {
                        UIApplication.shared.open(privacyURL)
                    }
                }) {
                    Text("Privacy Policy")
                        .foregroundColor(Color.white)
                        .padding(6)
                        .background(AppConstants.Colors.YKColor)
                        .cornerRadius(15)
                }.padding(4)
                Button(action: {
                    if let termsURL = AppConstants.URL.termsPolicy.url {
                        UIApplication.shared.open(termsURL)
                    }
                }) {
                    Text("Terms & Conditions")
                        .foregroundColor(Color.white)
                        .padding(6)
                        .background(AppConstants.Colors.YKColor)
                        .cornerRadius(15)
                }.padding(4)
                Toggle(isOn: self.$accepted) {
                    Text("Do you agree to our terms?")
                        .foregroundColor(Color.white)
                }.padding()
            }.padding(60)
        }.frame(width: 375)
    }
}
