//
//  YKNotification.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public struct YKNotification: Identifiable {
    public var id: String = UUID().uuidString
    public var title: String
    public var message: String
    public var action: Any
}
