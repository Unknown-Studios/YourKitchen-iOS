//
//  AppDelegate.swift
//  iOS-Template
//
//  Created by Markus Moltke on 23/04/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import UIKit

// Firebase
import Firebase
import FirebaseMessaging

// Authentication
import FBSDKLoginKit
import GoogleSignIn

// Advertisement
import GoogleMobileAds
import AdSupport

// Premium
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    public static var showMealplan: Bool = false
    public static var recipeID: String?
    public static var userID: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                    if let nextMonth = purchase.transaction.transactionDate?.addDays(value: 32) {
                        YKNetworkManager.Users.update(array: ["premium": nextMonth])
                    }
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    fatalError()
                }
            }
        }
        
        

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["20c19472f846ae6ffbbb3b88c51ec26a", "0FB58F97-7682-40D3-AA1D-600188123FC8"]
        GADMobileAds.sharedInstance().start { status in
            print("Started AdMob: " + status.debugDescription)
            for stat in status.adapterStatusesByClassName {
                print(stat.key + ": " + stat.value.description)
            }
        }
        
        print(ASIdentifierManager.shared().advertisingIdentifier)

        if CommandLine.arguments.contains("-uiTesting") {
            UserDefaults.standard.set(true, forKey: "privacyConsent")
            UserDefaults.standard.set(true, forKey: "adConsent")
            UserDefaults.standard.set(true, forKey: "onboardingDone")
            let fauth = Auth.auth()
            do {
                try fauth.signOut()
                SocialLoginViewModel().testSignIn { done in
                    print(done.description)
                }
                UIView.setAnimationsEnabled(false)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any])
        -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url)

        let facebookDidHandle = ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

        return googleDidHandle || facebookDidHandle
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print full message.
        print("Did receive noitification")

        Messaging.messaging().appDidReceiveMessage(userInfo)
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        if let userID = userInfo["user"] as? String {
            AppDelegate.userID = userID
        } else if let recipeID = userInfo["recipe"] as? String {
            AppDelegate.recipeID = recipeID
        }

        UIApplication.shared.applicationIconBadgeNumber += 1

        // Change this to your preferred presentation option
        return completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print full message.
        print("Did receive noitification")

        if let userID = userInfo["user"] as? String {
            AppDelegate.userID = userID
        } else if let recipeID = userInfo["recipe"] as? String {
            AppDelegate.recipeID = recipeID
        }

        UIApplication.shared.applicationIconBadgeNumber += 1

        completionHandler()
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        YKNetworkManager.Messaging.updateDeviceToken(fcmToken)
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        windows
            .filter { $0.isKeyWindow }
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged { _ in
        UIApplication.shared.endEditing(true)
    }

    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        modifier(ResignKeyboardOnDragGesture())
    }
}
