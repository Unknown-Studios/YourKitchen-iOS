//
//  Recipe.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import FirebaseFirestore

public class Recipe: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var name: String
    public var description: String
    public var type: Cuisine
    public var recipeType: RecipeType
    public var preparationTime: Time
    public var image: String
    public var ingredients: [Ingredient]
    public var steps = [String]()
    public var rating: Int = 0
    public var persons: Int = 4
    
    public var recipes = [Recipe]() //Ingredients as Recipes
    
    //Misc
    public var author: YKUser
    public var dateAdded = Date.start
    public var reference: DocumentReference?
    
    //Recipe can have list of recipes

    public static var none: Recipe {
        Recipe(id: "none",
               name: "",
               description: "",
               type: .american,
               recipeType: .main,
               preparationTime: Time(hour: 0, minute: 0),
               image: "",
               ingredients: [],
               persons: 4,
               author: YKUser.none)
    }

    init(id: String = UUID().uuidString, name: String, description: String, type: Cuisine, recipeType: RecipeType, preparationTime: Time, image: String, ingredients: [Ingredient], steps : [String] = [String](), recipes : [Recipe] = [Recipe](), rating: Int = 0, persons: Int = 4, author: YKUser, dateAdded: Date = Date.start, reference: DocumentReference? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.recipeType = recipeType
        self.preparationTime = preparationTime
        self.image = image
        self.ingredients = ingredients
        self.steps = steps
        self.recipes = recipes
        self.rating = rating
        self.persons = persons
        self.author = author
        self.dateAdded = dateAdded
        self.reference = reference
    }

    var desc: String {
        name + " " + id
    }

    func getIngredientsForPersons(person: Int) -> [Ingredient] {
        var tmpIngredients = [Ingredient]()
        for ing in ingredients {
            let tmpIng = ing
            tmpIng.amount = ing.amount * (Double(person) / Double(persons))
            tmpIngredients.append(tmpIng)
        }
        return tmpIngredients
    }

    /**
     Returns true if none of the allergens provided is contained in the dish's ingredients
     */
    func checkAllergenes(allergenes: [Allergen]) -> Bool {
        var recipeAllergens = [Allergen]()
        for r in ingredients where r.allergen != nil {
            if !recipeAllergens.contains(r.allergen!) { // No reason for duplicates
                recipeAllergens.append(r.allergen!)
            }
        }
        for a in allergenes {
            if recipeAllergens.contains(a) {
                return false
            }
        }
        return true
    }

    var idHex: Int {
        if let tmp = Int(Data(id.utf8).map { String(format: "%02x", $0) }.filter { Int($0) != nil }.joined()) {
            return tmp
        } else {
            return 0
        }
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        author = try values.decode(YKUser.self, forKey: .author)
        persons = (try? values.decode(Int.self, forKey: .persons)) ?? 4
        type = (try? values.decode(Cuisine.self, forKey: .type)) ?? .american
        recipeType = (try? values.decode(RecipeType.self, forKey: .recipeType)) ?? .main
        preparationTime = try values.decode(Time.self, forKey: .preparationTime)
        image = try values.decode(String.self, forKey: .image)
        if let ingredients = try? values.decode(String.self, forKey: .ingredients) {
            print("Using old system")
            let ingredientsData = ingredients.data(using: .utf8)
            self.ingredients = try JSONDecoder().decode([Ingredient].self, from: ingredientsData!)
        } else {
            let ingredients = try values.decode([Ingredient].self, forKey: .ingredients)
            self.ingredients = ingredients
        }
        self.recipes = (try? values.decode([Recipe].self, forKey: .recipes)) ?? [Recipe]()
        steps = try values.decode([String].self, forKey: .steps)
        rating = (try? values.decode(Int.self, forKey: .rating)) ?? 0
        dateAdded = (try? values.decode(Date.self, forKey: .dateAdded)) ?? Date.start
        reference = try? values.decode(DocumentReference.self, forKey: .reference)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case type
        case recipeType
        case preparationTime
        case image
        case ingredients
        case steps
        case rating
        case persons
        case recipes
        case author
        case dateAdded
        case reference
    }
}

extension Recipe: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum RecipeType: String, CaseIterable, Codable {
    case main = "Main"
    case side = "Side"
    case drink = "Drink"
    case ingredient = "Ingredient"

    public static func reverseString(_ value: String) throws -> RecipeType {
        switch value {
        case "Main": return .main
        case "Side": return .side
        case "Drink": return .drink
        case "Ingredient": return .ingredient
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

    static let all = RecipeType.allCases.map(\.rawValue)
}

public enum Cuisine: String, CaseIterable, Codable {
    case american = "American"
    case brazilian = "Brazilian"
    case british = "British"
    case caribbean = "Caribbean"
    case chinese = "Chinese"
    case danish = "Danish"
    case french = "French"
    case greek = "Greek"
    case indian = "Indian"
    case italian = "Italian"
    case japanese = "Japanese"
    case mediterranean = "Mediterranean"
    case mexican = "Mexican"
    case moroccan = "Moroccan"
    case spanish = "Spanish"
    case thai = "Thai"
    case turkish = "Turkish"
    case vietnamese = "Vietnamese"
    case other = "Other"

    public static func reverseString(_ value: String) throws -> Cuisine {
        switch value {
        case "American": return .american
        case "Brazilian": return .brazilian
        case "British": return .british
        case "Caribbean": return .caribbean
        case "Chinese": return .chinese
        case "Danish": return .danish
        case "French": return .french
        case "Greek": return .greek
        case "Indian": return .indian
        case "Italian": return .italian
        case "Japanese": return .japanese
        case "Mediterranean": return .mediterranean
        case "Mexican": return .mexican
        case "Moroccan": return .moroccan
        case "Spanish": return .spanish
        case "Thai": return .thai
        case "Turkish": return .turkish
        case "Vietnamese": return .vietnamese
        case "Other": return .other
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

    static let all = Cuisine.allCases.map(\.rawValue)
}
