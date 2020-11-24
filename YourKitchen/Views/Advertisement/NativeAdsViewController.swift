//
//  NativeAdsViewController.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Combine
import GoogleMobileAds
import SwiftUI

final class NativeAdsViewController: NSObject, UIViewControllerRepresentable {
    var adLoader: GADAdLoader?
    var templateView: GADTMediumTemplateView?

    let adUnitID: String

    private var cancellables = Set<AnyCancellable>()

    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }

    func makeUIViewController(context _: UIViewControllerRepresentableContext<NativeAdsViewController>) -> UIViewController {
        let templateView = GADTMediumTemplateView()
        self.templateView = templateView

        let viewController = UIViewController()

        viewController.view.addSubview(templateView)
        templateView.addHorizontalConstraintsToSuperviewWidth()
        templateView.addVerticalCenterConstraintToSuperview()

        #if DEBUG
            let adUnitID = "ca-app-pub-3940256099942544/3986624511"
        #else
            let adUnitID = self.adUnitID
        #endif

        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        let adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: rootViewController, adTypes: [GADAdLoaderAdType.unifiedNative], options: nil)
        adLoader.delegate = self

        self.adLoader = adLoader

        let request = GADRequest()
        let extras = GADExtras()
        if UserDefaults.standard.bool(forKey: "adConsent") {
            extras.additionalParameters = ["npa": "1"]
        }
        request.register(extras)
        adLoader.load(request)

        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: UIViewControllerRepresentableContext<NativeAdsViewController>) {}
}

extension NativeAdsViewController: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("Loaded ad")
        templateView?.nativeAd = nativeAd
    }

    func adLoader(_: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Found error while loading admob: " + error.localizedDescription)
    }
}
