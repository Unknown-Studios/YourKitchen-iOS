//
//  Invitation.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public struct Invitation: Identifiable {
    public var id: String = UUID().uuidString
    public var owner: YKUser
    public var other: YKUser
    public var date = Date()
    public var type: String
}

extension Invitation: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        owner = try values.decode(YKUser.self, forKey: .owner)
        other = try values.decode(YKUser.self, forKey: .other)
        date = try values.decode(Date.self, forKey: .date)
        type = try values.decode(String.self, forKey: .type)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case other
        case date
        case type
    }
}
