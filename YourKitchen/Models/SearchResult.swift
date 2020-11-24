//
//  SearchResult.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public class SearchResult: Identifiable, Decodable {
    public var id: String
    public var name: String
    public var type: String
    public var score: Double
    public var image: String?
    public var object: Any?

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        type = try values.decode(String.self, forKey: .type)
        score = try values.decode(Double.self, forKey: .score)
        image = try? values.decode(String.self, forKey: .image)
        switch type {
        case "recipe":
            object = try values.decode(Recipe.self, forKey: .data)
        case "ingredient":
            object = try values.decode(Ingredient.self, forKey: .data)
        case "user":
            object = try values.decode(YKUser.self, forKey: .data)
        default:
            print("Type not defined in search")
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case score
        case image
        case data
    }
}

extension SearchResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
