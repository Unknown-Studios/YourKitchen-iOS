//
//  Network.swift
//  YourKitchen
//
//  Created by Markus Moltke on 06/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public struct NetworkCache {
    public var recipes: [Recipe]?
    public var ingredients: [Ingredient]?
    public var refrigerator: Refrigerator?
    public var mealplan: Mealplan?
    public var users: [YKUser]?
}
