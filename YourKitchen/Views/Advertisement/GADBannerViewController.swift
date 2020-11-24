//
//  GADBannerViewController.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import GoogleMobileAds
import SwiftUI
import UIKit

struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
        #if DEBUG
//        let nativeAdvancedVideo = "ca-app-pub-3940256099942544/2521693316"
        let adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        let adUnitID = "ca-app-pub-5947064851146376/7264689535"
        #endif
        view.adUnitID = adUnitID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        
        let request = GADRequest()
        let extras = GADExtras()
        if (UserDefaults.standard.bool(forKey: "adConsent")) {
            extras.additionalParameters = ["npa": "1"]
        }
        request.register(extras)
        view.load(request)
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
