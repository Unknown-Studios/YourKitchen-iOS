//
//  Ingredient.swift
//  WatchOS Extension
//
//  Created by Markus Moltke on 07/11/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

class Ingredient: Identifiable, Codable { //We need a custom version for watch, because firestore doesn't work on watchos
    init(name: String, units: [String], ownerId: String) {
        self.ownerId = ownerId
        id = UUID().uuidString
        self.name = name
        self.units = units
    }

    public var id: String
    public var name: String
    public var ownerId: String
    public var amount: Double = 0.0
    public var units = [String]() // Will select [0] when used
    public var count: Int = 0

    var unit: String {
        get {
            (units.count > 0) ? units[0] : ""
        }
        set {
            units[0] = newValue
        }
    }

    var amountDescription: String {
        if amount.truncatingRemainder(dividingBy: 1.0) == 0.0 {
            return String(format: "%.0f", amount) + unit
        } else {
            return amount.description + unit
        }
    }

    var description: String {
        if amount.truncatingRemainder(dividingBy: 1.0) == 0.0 {
            return String(format: "%.0f", amount) + unit + " - " + name
        } else {
            return amount.description + unit + " - " + name
        }
    }

    public static var none: Ingredient {
        Ingredient(name: "None", units: [""], ownerId: "")
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ownerId = (try? values.decode(String.self, forKey: .ownerId)) ?? "U8uKwZi7LmhUKKyhpgjuQTjtGHc2"
        name = try values.decode(String.self, forKey: .name)
        amount = (try? values.decode(Double.self, forKey: .amount)) ?? 0.0
        units = try values.decode([String].self, forKey: .units)
        count = (try? values.decode(Int.self, forKey: .count)) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case name
        case amount
        case units
        case count
    }
}

extension Ingredient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
