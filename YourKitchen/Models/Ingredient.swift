//
//  Ingredient.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseFirestore

public class Ingredient: Identifiable, Codable {
    init(name: String, units: [String], ownerId: String, type: IngredientType, allergen: Allergen? = nil) {
        self.ownerId = ownerId
        id = UUID().uuidString
        self.name = name
        self.units = units
        self.type = type
        self.allergen = allergen
    }

    public var id: String
    public var name: String
    public var ownerId: String
    public var amount: Double = 0.0
    public var units = [String]() // Will select [0] when used
    public var count: Int = 0
    public var type: IngredientType
    public var allergen: Allergen?
    public var reference: DocumentReference?

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
        Ingredient(name: "None", units: [""], ownerId: "", type: .vegetables)
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ownerId = (try? values.decode(String.self, forKey: .ownerId)) ?? "U8uKwZi7LmhUKKyhpgjuQTjtGHc2"
        name = try values.decode(String.self, forKey: .name)
        amount = (try? values.decode(Double.self, forKey: .amount)) ?? 0.0
        units = try values.decode([String].self, forKey: .units)
        count = (try? values.decode(Int.self, forKey: .count)) ?? 0
        type = try values.decode(IngredientType.self, forKey: .type)
        allergen = try? values.decode(Allergen.self, forKey: .allergen)
        reference = try? values.decode(DocumentReference.self, forKey: .reference)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case name
        case amount
        case units
        case count
        case type
        case allergen
        case reference
    }
}

extension Ingredient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum IngredientType: String, CaseIterable, Codable, Identifiable {
    case vegetables = "Vegetables"
    case spices = "Spices and herbs"
    case cereals = "Cereals"
    case meat = "Meat"
    case dairy = "Dairy"
    case fruits = "Fruits"
    case seafood = "Seafood"
    case powders = "Powders"
    case nuts = "Nuts"
    case oils = "Oils"
    case other = "Other"

    public var id: IngredientType {
        self
    }

    public static func reverseString(_ value: String) throws -> IngredientType {
        switch value {
        case "Vegetables": return .vegetables
        case "Spices and herbs": return .spices
        case "Cereals": return .cereals
        case "Meat": return .meat
        case "Dairy": return .dairy
        case "Fruits": return .fruits
        case "Seafood": return .seafood
        case "Powders": return .powders
        case "Nuts": return .nuts
        case "Oils": return .oils
        case "Other": return .other
        default: throw CaseNameCodableError(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        if let raw = Self.allCases.first(where: { $0.caseName == value })?.rawValue {
            self.init(rawValue: raw)!
        } else if let raw = Self.allCases.first(where: { $0.rawValue == value })?.rawValue {
            self.init(rawValue: raw)!
        } else {
            throw CaseNameCodableError(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(caseName)
    }

    public var caseName: String {
        "\(self)"
    }

    public var prettyName: String {
        "\(self)".capitalizingFirstLetter()
    }

    static let all = IngredientType.allCases.map(\.rawValue)

    struct TupleStruct: Hashable {
        var name: String
        var index: Int
    }

    static var allIndexed: [TupleStruct] {
        var tupleArray: [TupleStruct] = []
        var ind: Int = 0

        for item in IngredientType.all // allCases.map({ $0.rawValue })
        {
            tupleArray += [TupleStruct(name: item, index: ind)]
            ind += 1
        }
        return tupleArray
    }
}

// A custom error type for decoding...
struct CaseNameCodableError: Error {
    private let caseName: String

    init(_ value: String) {
        caseName = value
    }

    var localizedDescription: String {
        #"Unable to create an enum case named "\#(caseName)""#
    }
}

public enum Allergen: String, CaseIterable, Codable {
    case eggs = "Eggs"
    case lactose = "Lactose"
    case nuts = "Nuts"
    case fish = "Fish"
    case shellfish = "Shellfish"
    case gluten = "Gluten"
    case soy = "Soy"

    public static func reverseString(_ value: String) throws -> Allergen {
        switch value {
        case "Eggs": return .eggs
        case "Lactose": return .lactose
        case "Nuts": return .nuts
        case "Fish": return .fish
        case "Shellfish": return .shellfish
        case "Gluten": return .gluten
        case "Soy": return .soy
        default: throw CaseNameCodableError(value)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        let newValue = value.replacingOccurrences(of: "\"", with: "")
        if let raw = Self.allCases.first(where: { $0.caseName == newValue })?.rawValue {
            self.init(rawValue: raw)!
        } else if let raw = Self.allCases.first(where: { $0.rawValue == newValue })?.rawValue {
            self.init(rawValue: raw)!
        } else {
            throw CaseNameCodableError(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(caseName)
    }

    public var caseName: String {
        "\(self)"
    }

    public var prettyName: String {
        "\(self)".capitalizingFirstLetter()
    }

    static let all = Allergen.allCases.map(\.rawValue)
    struct TupleStruct: Hashable {
        var name: String
        var index: Int
    }

    static var allIndexed: [TupleStruct] {
        var tupleArray: [TupleStruct] = []
        var ind: Int = 0

        for item in Allergen.all // allCases.map({ $0.rawValue })
        {
            tupleArray += [TupleStruct(name: item, index: ind)]
            ind += 1
        }
        return tupleArray
    }
}
