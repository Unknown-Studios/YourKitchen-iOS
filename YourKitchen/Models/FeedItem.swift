//
//  FeedItem.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseFirestore

public struct FeedItem: Identifiable {
    public var id = UUID().uuidString
    public var owner: YKUser
    public var description: String?
    public var recipe: Recipe
    public var dateAdded: Date
    public var reference: DocumentReference?

    init(owner: YKUser? = nil, description: String?, recipe: Recipe, dateAdded: Date = Date()) {
        if owner == nil {
            if let user = YKNetworkManager.shared.currentUser {
                self.owner = user
            } else {
                print("You need to provide an ownerId")
                self.owner = YKUser(name: "", email: "", image: "", following: [])
            }
        } else {
            self.owner = owner!
        }
        self.description = description
        self.recipe = recipe
        self.dateAdded = dateAdded
    }
}

extension FeedItem: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        owner = try values.decode(YKUser.self, forKey: .owner)
        recipe = try values.decode(Recipe.self, forKey: .recipe)
        description = (try? values.decode(String.self, forKey: .description)) ?? nil
        dateAdded = try values.decode(Date.self, forKey: .dateAdded)
        reference = try? values.decode(DocumentReference.self, forKey: .reference)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case description
        case recipe
        case dateAdded
        case reference
    }
}
