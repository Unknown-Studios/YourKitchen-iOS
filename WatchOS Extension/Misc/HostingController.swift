//
//  HostingController.swift
//  WatchOS Extension
//
//  Created by Markus Moltke on 01/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import SwiftUI
import WatchConnectivity
import WatchKit

class HostingController: WKHostingController<AnyView>, WCSessionDelegate {
    var userSettings = UserSettings()

    override init() {
        super.init()

        if WCSession.isSupported() {
            print("WCSession supported")
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    override var body: AnyView {
        AnyView(ContentView().environmentObject(userSettings))
    }

    // MARK: - WCSessionDelegate

    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
    }

    func handleMessage(_ message: [String: Any]) {
        if let accountJSON = message["main-account"] as? String {
            print("Received this: \(accountJSON)")
            UserDefaults.standard.set(accountJSON, forKey: "main-account")
            DispatchQueue.main.async {
                self.userSettings.uid = accountJSON
            }
        }
        if let signout = message["sign-out"] as? Bool, signout {
            print("Signing out")
            DispatchQueue.main.async {
                self.userSettings.uid = nil
            }
        }
    }

    func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        NSLog("didReceiveApplicationContext : %@", applicationContext)
        handleMessage(applicationContext)
    }

    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler _: @escaping ([String: Any]) -> Void) {
        handleMessage(message)
    }

    func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        handleMessage(message)
    }

    func session(_: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        handleMessage(userInfo)
    }
}
