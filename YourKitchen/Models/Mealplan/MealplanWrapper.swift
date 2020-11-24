//
//  MealplanWrapper.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Combine
import Foundation

public class MealplanWrapper: ObservableObject {
    @Published public var owner: YKUser
    @Published public var mealplan: Mealplan

    init(_ owner: YKUser, mealplan: Mealplan) {
        self.owner = owner
        self.mealplan = mealplan
    }
}
