//
//  NotificationToken.swift
//  YourKitchen
//
//  Created by Markus Moltke on 08/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public struct NotificationToken: Codable {
    public var device: String
    public var token: String
}
