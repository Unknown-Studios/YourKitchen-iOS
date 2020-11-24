//
//  OnboardingView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 24/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import AdSupport
import AppTrackingTransparency
import ConcentricOnboarding
import SwiftUI

struct OnboardingView: View {
    @Binding var showing: Bool
    @State var currentIndex = 0
    @State var adConsent: Bool = true
    @State var privacyConsent: Bool = false
    @State var likes = [Cuisine]()

    init(showing: Binding<Bool>) {
        _showing = showing
    }

    var body: some View {
        let pages = [
            AnyView(PageView(header: "Feed", content: "Personalize your own feed.")),
            AnyView(PageView(header: "Explore", content: "Get inspired with new recipes.")),
            AnyView(PageView(header: "Refrigerator", content: "Keep track of your refrigerator.")),
            AnyView(PageView(header: "Meal Plan", content: "Create your own meal plan and share it with friends and family.")),
            AnyView(LikesOnboardingView(likes: self.$likes)),
            AnyView(AdConsentView(accepted: self.$adConsent)),
            AnyView(PrivacyConsent(accepted: self.$privacyConsent))
        ]
        let otherColor = Color(.displayP3, red: (99.0/255.0), green: (159.0/255.0), blue: 1.0, opacity: 1.0)
        let colors = [
            AppConstants.Colors.YKColor,
            otherColor,
            AppConstants.Colors.YKColor,
            otherColor,
            AppConstants.Colors.YKColor,
            Color.orange,
            Color.red
        ]

        var a = ConcentricOnboardingView(pages: pages, bgColors: colors)

        a.didPressNextButton = {
            print(self.currentIndex)
            if self.currentIndex == pages.count - 3 {
                if likes.count == 0 { //Should select at least 1
                    return
                } else {
                    var array = [String: Int]()
                    for like in likes {
                        array[like.caseName] = 10
                    }
                    UserDefaults.standard.set(array, forKey: "likes")
                    YKNetworkManager.Interests.update(ratings: array)
                }
            }
            if (self.currentIndex == pages.count - 4 && (UserDefaults.standard.dictionary(forKey: "likes") != nil)) {
                self.currentIndex += 1 //Skip likes if we have already done it
            }
            if self.currentIndex == pages.count - 3 && UserDefaults.standard.bool(forKey: "privacyConsent") { //If we completed privacy and ad consent before just skip it
                UserDefaults.standard.set(true, forKey: "onboardingDone")
                print("Onboarding done")
                self.showing = false
                return
            }
            if self.currentIndex == pages.count - 2 { //Ad consent
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                        UserDefaults.standard.set(status == .authorized, forKey: "adConsent")
                        self.currentIndex += 1
                        a.goToNextPage(animated: true)
                    })
                    return
                } else {
                    UserDefaults.standard.set(self.adConsent, forKey: "adConsent")
                    self.currentIndex += 1
                    a.goToNextPage(animated: true)
                    return
                }
            }
            if self.currentIndex != pages.count - 1 { //If not covered in previous cases
                self.currentIndex += 1
                a.goToNextPage(animated: true)
                return
            }

            if self.privacyConsent { // If last page and privacy policy accepted
                UserDefaults.standard.set(self.privacyConsent, forKey: "privacyConsent")
                UserDefaults.standard.set(true, forKey: "onboardingDone")
                self.showing = false
                // Only updates user if it exists, otherwise it is handled in the user creation.
                YKNetworkManager.Users.update(array: ["adConsent": self.adConsent, "privacyConsent": self.privacyConsent])
                if let likes = UserDefaults.standard.dictionary(forKey: "likes") as? [String : Int] {
                    YKNetworkManager.Interests.update(likes: likes)
                }
            }
        }
        return a
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showing: .constant(true))
    }
}
