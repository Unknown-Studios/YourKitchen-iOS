//
//  SocialMealplan.swift
//  YourKitchen
//
//  Created by Markus Moltke on 10/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public class SocialMealplan: Identifiable, Hashable, ObservableObject {
    public var id: String {
        owner.id
    }

    @Published public var owner: YKUser
    @Published public var mealplan: Mealplan

    init(owner: YKUser, mealplan: Mealplan) {
        self.owner = owner
        self.mealplan = mealplan
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
