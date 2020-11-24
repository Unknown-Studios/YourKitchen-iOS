//
//  ConsentView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct AdConsentView: View {
    @Binding var accepted: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Ad Consent")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.white)
                Text("We care about your privacy and data security.").foregroundColor(Color.white)
                Text("Can we use your data to tailor ads for you?")
                    .font(.title)
                    .lineLimit(3)
                    .foregroundColor(Color.white)
                Text("changeConsent").lineLimit(8)
                    .foregroundColor(Color.white)
                Text("partners")
                    .foregroundColor(Color.white)
                    .padding()
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
                }
                if #available(iOS 14, *) {
                } else {
                    Toggle(isOn: self.$accepted) {
                        Text("Tailored ads?").foregroundColor(Color.white)
                    }.padding()
                }
            }.padding(60)
        }.frame(width: 375)
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters:
                                [AnalyticsParameterScreenName: "Ad Consent",
                                 AnalyticsParameterScreenClass: AdConsentView.self])
        }
    }
}
