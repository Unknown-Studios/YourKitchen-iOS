//
//  Meal.swift
//  YourKitchen
//
//  Created by Markus Moltke on 31/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public struct Meal: Identifiable {
    public var id: String {
        return recipe.id + date.description
    }
    var date: Date
    var recipe: Recipe

    var description: String {
        return date.description + ": " + recipe.desc
    }
}

extension Meal: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Meal: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let time = try? values.decode(Int.self, forKey: .date) { //To work better together with the backend
            date = Date(timeIntervalSince1970: TimeInterval(time))
        } else {
            self.date = try values.decode(Date.self, forKey: .date)
        }
        recipe = (try? values.decode(Recipe.self, forKey: .recipe)) ?? Recipe.none
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(recipe, forKey: .recipe)
    }

    enum CodingKeys: String, CodingKey {
        case date
        case recipe
    }
}
