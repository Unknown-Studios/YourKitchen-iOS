//
//  ShoppingList.swift
//  YourKitchen
//
//  Created by Markus Moltke on 15/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseFirestore

public struct ShoppingList: Identifiable {
    public var id: String = UUID().uuidString
    public var ownerId: String
    public var ingredients = [Ingredient]()
    public var reference: DocumentReference?

    public static var none: ShoppingList {
        ShoppingList(id: "none", ownerId: "")
    }
}

extension ShoppingList: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ownerId = try values.decode(String.self, forKey: .ownerId)
        ingredients = try values.decode([Ingredient].self, forKey: .ingredients)
        reference = try? values.decode(DocumentReference.self, forKey: .reference)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case ingredients
        case reference
    }
}
