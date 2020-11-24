//
//  RecipeViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

class RecipeViewModel {
    var currentAdIndex = 0
    var nextAd = 0
    var chance = 6 ..< 12

    init() {
        _ = shouldShowAd() // Prevents first item from being an ad
    }

    func shouldShowAd() -> Bool {
        currentAdIndex += 1
        if nextAd == 0 {
            nextAd = currentAdIndex + Int.random(in: 2 ..< 12)
        }
        if currentAdIndex >= nextAd {
            nextAd = currentAdIndex + Int.random(in: chance)
            return true
        }
        return false
    }
}
