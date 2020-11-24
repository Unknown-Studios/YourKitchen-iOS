//
//  Mealplan.swift
//  YourKitchen
//
//  Created by Markus Moltke on 30/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

public class Mealplan: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var ownerId: String
    public var shareIDs: [String]
    public var reference: DocumentReference?

    private var _meals = [Date: Recipe]()
    public var meals: [Meal] {
        get {
            _meals.map { Meal(date: $0.key, recipe: $0.value) }.sorted(by: { $0.date < $1.date })
        }
        set {
            _meals = [Date: Recipe]() // Reset
            for meal in newValue { // Set new values
                _meals[meal.date] = meal.recipe
            }
        }
    }

    subscript(idx: Date) -> Recipe {
        get {
            _meals[idx]!
        }
        set {
            _meals[idx] = newValue
        }
    }

    init(ownerId: String, meals: [Meal]) {
        shareIDs = []
        self.ownerId = ownerId
        self.meals = meals
    }

    init(meals: [Meal]) {
        guard let user = Auth.auth().currentUser else {
            fatalError("You need to be logged in to use this initializer")
        }
        ownerId = user.uid
        shareIDs = []
        self.meals = meals
    }

    init() {
        guard let user = Auth.auth().currentUser else {
            fatalError("You need to be logged in to use this initializer")
        }
        ownerId = user.uid
        shareIDs = []
        meals = [Meal]()
    }

    fileprivate init(id: String) {
        self.id = id
        ownerId = ""
        shareIDs = []
        meals = [Meal]()
    }

    public static var none: Mealplan {
        Mealplan(id: "none")
    }

    public static var emptyMealplan: [Meal] {
        var tmpMealplan = [Meal]()
        tmpMealplan.append(Meal(date: Date.start, recipe: Recipe.none)) // 0
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 1), recipe: Recipe.none))
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 2), recipe: Recipe.none))
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 3), recipe: Recipe.none))
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 4), recipe: Recipe.none))
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 5), recipe: Recipe.none))
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 6), recipe: Recipe.none))
        tmpMealplan.append(Meal(date: Date.start.addDays(value: 7), recipe: Recipe.none))
        return tmpMealplan
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ownerId = try values.decode(String.self, forKey: .ownerId)
        shareIDs = (try? values.decode([String].self, forKey: .shareIDs)) ?? [String]()
        print("BEFORE MEALS")
        meals = try values.decode([Meal].self, forKey: .meals)
        print("AFTER MEALS")
        reference = try? values.decode(DocumentReference.self, forKey: .reference)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(shareIDs, forKey: .shareIDs)
        try container.encode(meals, forKey: .meals)
        try container.encode(reference, forKey: .reference)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case meals
        case shareIDs
        case reference
    }
}

extension Mealplan: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Array {
    func unique(map: (Element) -> (Mealplan)) -> [Element] {
        var set = Set<Mealplan>() // the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() // keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
