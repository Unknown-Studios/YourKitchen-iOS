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
        
        templateView.layer.cornerRadius = 10
        templateView.clipsToBounds = true
        templateView.frame = CGRect(x: 0, y: 0, width: 325, height: 325)
        //templateView.callToActionView?.isHidden = true
        

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
        let adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: rootViewController, adTypes: [GADAdLoaderAdType.native], options: nil)
        adLoader.delegate = self

        self.adLoader = adLoader

        let request = GADRequest()
        if UserDefaults.standard.bool(forKey: "adConsent") {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        adLoader.load(request)

        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: UIViewControllerRepresentableContext<NativeAdsViewController>) {}
}

extension NativeAdsViewController: GADNativeAdLoaderDelegate {
    func adLoader(_: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("Loaded ad")
        templateView?.nativeAd = nativeAd
    }

    func adLoader(_: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print (error.localizedDescription)
        // Gets the domain from which the error came.
//        let errorDomain = error
//        // Gets the error code. See
//        // https://developers.google.com/admob/ios/api/reference/Enums/GADErrorCode
//        // for a list of possible codes.
//        let errorCode = error
//        // Gets an error message.
//        // For example "Account not approved yet". See
//        // https://support.google.com/admob/answer/9905175 for explanations of
//        // common errors.
//        let errorMessage = error.localizedDescription
//        // Gets additional response information about the request. See
//        // https://developers.google.com/admob/ios/response-info for more information.
//        let responseInfo = error.userInfo[GADErrorUserInfoKeyResponseInfo] as? GADResponseInfo
//        // Gets the underlyingError, if available.
//        let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error
//        if let responseInfo = responseInfo {
//            print("Received error with domain: \(errorDomain), code: \(errorCode),"
//              + "message: \(errorMessage), responseInfo: \(responseInfo),"
//              + "underLyingError: \(underlyingError?.localizedDescription ?? "nil")")
//        }
        #if !DEBUG
            templateView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        #endif
    }
}
