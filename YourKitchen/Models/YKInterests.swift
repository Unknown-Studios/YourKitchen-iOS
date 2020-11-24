//
//  Interests.swift
//  YourKitchen
//
//  Created by Markus Moltke on 07/11/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public class YKInterests: Identifiable, Codable {
    public var id: String
    public var likes: [String: Int]
    public var ratings: [String: Int]
    public var ownerId: String

    init(id: String = UUID().uuidString, likes: [String: Int], ratings: [String: Int], ownerId: String) {
        self.id = id
        self.likes = likes
        self.ratings = ratings
        self.ownerId = ownerId
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        likes = try values.decode([String: Int].self, forKey: .likes)
        ratings = try values.decode([String: Int].self, forKey: .ratings)
        ownerId = try values.decode(String.self, forKey: .ownerId)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case likes
        case ratings
        case ownerId
    }
}
