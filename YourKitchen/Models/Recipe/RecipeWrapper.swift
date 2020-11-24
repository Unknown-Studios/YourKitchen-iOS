//
//  RecipeWrapper.swift
//  YourKitchen
//
//  Created by Markus Moltke on 18/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import SwiftUI

public class RecipeWrapper: ObservableObject {
    @Published public var recipe: Recipe

    init(_ recipe: Recipe) {
        self.recipe = recipe
    }
}
