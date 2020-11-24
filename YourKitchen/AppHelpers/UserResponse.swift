//
//  UserResponse.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public enum UserResponse {
    public static func displayError(msg: String, title _: String = "") {
        print("Error: " + msg)
        #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}
