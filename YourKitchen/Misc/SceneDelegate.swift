//
//  SceneDelegate.swift
//  iOS-Template
//
//  Created by Markus Moltke on 23/04/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppConstants.Colors.YKColor.uiColor()]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: AppConstants.Colors.YKColor.uiColor()]

        // Handle todayview
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let qp = connectionOptions.urlContexts.first?.url.queryParameters
            let urlComp = URLComponents(string: connectionOptions.urlContexts.first?.url.absoluteString ?? "")
            if let urlComp = urlComp { // Handle recipe
                if urlComp.host == "recipe" {
                    if let qp = qp, let id = qp["id"] {
                        AppDelegate.recipeID = id
                    }
                } else if urlComp.host == "mealplan" {
                    AppDelegate.showMealplan = true
                }
            }

            if window.rootViewController == nil {
                window.rootViewController = UIHostingController(rootView: InitialLoadView())
            }
            SpotlightHelper.setupSearchableContent()
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let qp = URLContexts.first?.url.queryParameters
        let urlComp = URLComponents(string: URLContexts.first?.url.absoluteString ?? "")
        if let urlComp = urlComp { // Handle recipe
            if urlComp.host == "recipe" {
                if let windowScene = scene as? UIWindowScene, let qp = qp, let id = qp["id"] {
                    let window = UIWindow(windowScene: windowScene)
                    AppDelegate.recipeID = id
                    window.rootViewController = UIHostingController(rootView: InitialLoadView())
                    self.window = window
                    window.makeKeyAndVisible()
                }
            } else if urlComp.host == "mealplan" {
                if let windowScene = scene as? UIWindowScene {
                    let window = UIWindow(windowScene: windowScene)
                    AppDelegate.showMealplan = true
                    window.rootViewController = UIHostingController(rootView: InitialLoadView())
                    self.window = window
                    window.makeKeyAndVisible()
                }
            }
        }
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
