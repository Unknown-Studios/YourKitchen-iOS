//
//  Refrigerator.swift
//  YourKitchen
//
//  Created by Markus Moltke on 11/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseFirestore

public class Refrigerator: Codable {
    var id: String = UUID().uuidString
    var ownerId: String
    var ingredients: [Ingredient]
    var shareID: String?
    var reference: DocumentReference?

    var isHost: Bool {
        shareID == nil
    }

    public static var none: Refrigerator {
        Refrigerator(id: "none", ownerId: "", ingredients: [])
    }

    init(id: String = UUID().uuidString, ownerId: String, ingredients: [Ingredient], shareID: String? = nil) {
        self.id = id
        self.ownerId = ownerId
        self.ingredients = ingredients
        self.shareID = shareID
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ownerId = try values.decode(String.self, forKey: .ownerId)
        ingredients = try values.decode([Ingredient].self, forKey: .ingredients)
        shareID = (try? values.decode(String.self, forKey: .shareID)) ?? nil
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case ingredients
        case shareID
    }
}
