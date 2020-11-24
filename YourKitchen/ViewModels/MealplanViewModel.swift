//
//  MealplanViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 31/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public class MealplanViewModel {
    public func updateMadeThis(recipe: Recipe) {
        print("Made this")
        YKNetworkManager.Refrigerators.get { refrigerator in
            var newIngredients = [Ingredient]()
            if let refrigerator = refrigerator {
                for ingredient in refrigerator.ingredients {
                    for recipeIngredient in recipe.ingredients {
                        if ingredient == recipeIngredient {
                            let tmpIngredient = ingredient
                            if let unit = Unit(symbol: ingredient.unit) as? UnitMass, let toUnit = Unit(symbol: recipeIngredient.unit) as? UnitMass {
                                let measurement1 = Measurement(value: ingredient.amount, unit: unit)
                                let measurement2 = Measurement(value: recipeIngredient.amount, unit: toUnit)
                                let finalMeasurement = measurement1 - measurement2
                                if finalMeasurement.value < 0 { // $ < 0
                                    tmpIngredient.amount = 0
                                } else if finalMeasurement.value == 0 { // $ == 0
                                    tmpIngredient.amount = 0
                                } else { // $ > 0
                                    tmpIngredient.amount = finalMeasurement.value
                                    tmpIngredient.unit = AppConstants.Measure.getUnitSymbol(unit: finalMeasurement.unit)
                                }
                            } else if let unit = Unit(symbol: ingredient.unit) as? UnitVolume, let toUnit = Unit(symbol: recipeIngredient.unit) as? UnitVolume {
                                let measurement1 = Measurement(value: ingredient.amount, unit: unit)
                                let measurement2 = Measurement(value: recipeIngredient.amount, unit: toUnit)
                                let finalMeasurement = measurement1 - measurement2
                                if finalMeasurement.value < 0 { // $ < 0
                                    tmpIngredient.amount = 0
                                } else if finalMeasurement.value == 0 { // $ == 0
                                    tmpIngredient.amount = 0
                                } else { // $ > 0
                                    tmpIngredient.amount = finalMeasurement.value
                                    tmpIngredient.unit = AppConstants.Measure.getUnitSymbol(unit: finalMeasurement.unit)
                                }
                            } else { // No unit
                                if ingredient.amount - recipeIngredient.amount < 0 { // $ < 0
                                    tmpIngredient.amount = 0
                                } else if ingredient.amount - recipeIngredient.amount == 0 { // $ == 0
                                    tmpIngredient.amount = 0
                                } else { // $ > 0
                                    tmpIngredient.amount = ingredient.amount - recipeIngredient.amount
                                }
                            }
                            newIngredients.append(tmpIngredient)
                        }
                    }
                }
                let tmpRefrigerator = refrigerator
                tmpRefrigerator.ingredients = YKNetworkManager.Ingredients.match(ingredients: newIngredients, storedIngredients: refrigerator.ingredients)
                YKNetworkManager.Refrigerators.update(refrigerator: refrigerator)
            }
        }
    }

    // - TODO: Better generation when using premium
    /**
     Generate a random mealplan for the recipes that are empty
     */
    func generateRandomMealplan(_ mealplan: Mealplan, completion: @escaping (Mealplan) -> Void) {
        var selectedDishes = [String]()
        for meal in mealplan.meals where !(meal.recipe == Recipe.none) && !selectedDishes.contains(meal.recipe.id) {
            // Generate new dish
            selectedDishes.append(meal.recipe.id)
        }
        let tmpMealplan = mealplan
        YKNetworkManager.Recipes.getAll { recipes in
            var maxTries = 20
            if premium { // Prefer recommended recipes
                SelectRecipeViewModel().getInterests(amount: 4) { recommendedRecipes in //Half of the mealplan is recommended dishes
                    let recipes = recipes.filter { $0.recipeType == .main }
                    for meal in mealplan.meals where meal.recipe == Recipe.none {
                        maxTries -= 1
                        if maxTries < 0 {
                            break
                        }
                        // Generate new dish
                        let result = self.getRandomRecipeWithRecommended(recommended: recommendedRecipes, recipes: recipes, reserved: selectedDishes)
                        tmpMealplan[meal.date] = result.0
                        selectedDishes = result.1
                    }
                    completion(tmpMealplan)
                }
            } else {
                let recipes = recipes.filter { $0.recipeType == .main }
                for meal in mealplan.meals where meal.recipe == Recipe.none {
                    maxTries -= 1
                    if maxTries < 0 {
                        break
                    }
                    // Generate new dish
                    let result = self.getRandomRecipe(recipes: recipes, reserved: selectedDishes)
                    tmpMealplan[meal.date] = result.0
                    selectedDishes = result.1
                }
                completion(tmpMealplan)
            }
        }
    }

    /**
     Get random recipe, but prefer recommended
     */
    private func getRandomRecipeWithRecommended(recommended: [Recipe], recipes: [Recipe], reserved: [String]) -> (Recipe, [String]) {
        let tmpRecipes = recipes.filter { (recipe) -> Bool in
            !reserved.contains(where: { $0 == recipe.id })
        }
        let tmpRecommended = recommended.filter { (recipe) -> Bool in
            !reserved.contains(where: { $0 == recipe.id })
        }

        if tmpRecommended.count > 0 && Int.random(in: 0..<1) == 0 { //To randomize recipes, so the recommended won't be chosen every time
            if let recipe = tmpRecommended.randomElement() {
                var tmpReserved = reserved
                tmpReserved.append(recipe.id)
                return (recipe, tmpReserved)
            }
        }

        if let recipe = tmpRecipes.randomElement() {
            var tmpReserved = reserved
            tmpReserved.append(recipe.id)
            return (recipe, tmpReserved)
        }
        return (Recipe.none, reserved)
    }

    /**
     Generate a random recipe
     */
    private func getRandomRecipe(recipes: [Recipe], reserved: [String]) -> (Recipe, [String]) {
        let tmpRecipes = recipes.filter { (recipe) -> Bool in
            !reserved.contains(where: { $0 == recipe.id })
        }
        if let recipe = tmpRecipes.randomElement() {
            var tmpReserved = reserved
            tmpReserved.append(recipe.id)
            return (recipe, tmpReserved)
        }
        return (Recipe.none, reserved)
    }

    /**
     Used to add/remove the appropiate recipes from the mealplan to keep 8  items in it at all times (Removes old recipes)
     */
    func maintainMealplan(mealplan: Mealplan, _ completion: @escaping (Mealplan) -> Void) {
        var updateCount = 0
        let tmpMealplan = mealplan
        var removedRecipes = [Recipe]()
        for meal in tmpMealplan.meals {
            if meal.date.isInThePast {
                updateCount += 1
                removedRecipes.append(meal.recipe)
                tmpMealplan.meals.removeAll(where: { $0.date == meal.date })
                tmpMealplan[meal.date.addDays(value: 8).start] = Recipe.none
            }
        }
        //Move items 8 days forward
        if updateCount >= 8 { //Reset mealplan if
            tmpMealplan.meals = Mealplan.emptyMealplan
        } else {
            var index = 0
            var maxTries = 20
            while tmpMealplan.meals.count < 8 && maxTries > 0 {
                maxTries -= 1
                if tmpMealplan.meals.first(where: { $0.date == Date.start.addDays(value: index) }) == nil {
                    tmpMealplan[Date.start.addDays(value: index)] = Recipe.none
                }
                index += 1
            }
        }
        generateRandomMealplan(tmpMealplan) { mealplan in
            let before = tmpMealplan.meals.filter { $0.recipe == Recipe.none }.map(\.recipe)
            let after = mealplan.meals.filter {
                $0.recipe.id != Recipe.none.id
            }.filter {
                !before.contains($0.recipe)
            }.map(\.recipe)
            self.fixShoppingList(removed: removedRecipes, new: after)
            YKNetworkManager.Mealplans.update(mealplan) { mealplan in
                completion(mealplan)
            }
        }
    }

    /**
     Used to keep the shopping list updated, sometimes this might fail minimally and remove a ingredient that was user added...

     - Parameters:
        - removed: The removed recipes
        - recipes: The new recipes
     */
    private func fixShoppingList(removed: [Recipe], new recipes: [Recipe]) {
        YKNetworkManager.Refrigerators.get { refrigerator in
            if let refrigerator = refrigerator {
                YKNetworkManager.ShoppingLists.get(refrigerator.ownerId) { shoppingList in
                    if var shoppingList = shoppingList {
                        guard let user = YKNetworkManager.shared.currentUser else { return }
                        var ingredients = [Ingredient]()
                        _ = recipes.map { ingredients.append(contentsOf: $0.getIngredientsForPersons(person: user.defaultPersons)) } // All ingredients in the new recipes

                        var removedIngredients = [Ingredient]() // All ingredients removed because the recipe changed without being made.
                        //We assume they were also added with default persons.
                        _ = removed.map { removedIngredients.append(contentsOf: $0.getIngredientsForPersons(person: user.defaultPersons)) }

                        // Combine ingredients amount
                        for item in ingredients {
                            let similar = ingredients.filter { $0 == item }
                            if similar.count > 1 { // If there is more than one of this item
                                let first = similar.first!
                                first.amount = 0.0
                                for sim in similar {
                                    first.amount += sim.amount
                                }
                                ingredients.removeAll(where: { $0 == first }) // Remove all similar ingredients
                                ingredients.append(first) // Add ingredient with new amounts
                            }
                        }

                        // Add ingredients that aren't already on the list
                        for ingredient in ingredients { // The ingredients to add..
                            let shoppingListItem = shoppingList.ingredients.filter { $0 == ingredient }.first // If the ingredient we are about to add already is in the shoppinglist
                            if let shoppingListItem = shoppingListItem {
                                shoppingList.ingredients.removeAll(where: { $0 == shoppingListItem })
                                if shoppingListItem.amount - ingredient.amount > 0 {
                                    // Shopping list amount is less than zero without the ingredient amount
                                    shoppingListItem.amount += shoppingListItem.amount - ingredient.amount
                                } else {
                                    // ShoppingList minus ingredient is under 0, set the amount to the new amount
                                    shoppingListItem.amount = ingredient.amount
                                }
                                shoppingList.ingredients.append(shoppingListItem) // Re-add with new amount
                            } else {
                                // If the ingredient isn't already there add it
                                shoppingList.ingredients.append(ingredient)
                            }
                        }

                        // Remove what we already have in our refrigerator
                        for ingredient in shoppingList.ingredients {
                            let refIng = refrigerator.ingredients.filter { $0 == ingredient }.first // Get the refrigerator ingredient from mealplan
                            let removedIngredient = removedIngredients.filter { $0 == ingredient }.first // Get the removedIngredient from mealplan
                            if let refIng = refIng { // If it exists
                                let tmpIngredient = ingredient // Convert to let
                                tmpIngredient.amount -= refIng.amount // Subtract the refrigerator ingredients amount
                                shoppingList.ingredients.removeAll(where: { $0 == tmpIngredient }) // Remove it from the shoppingList
                                if tmpIngredient.amount > 0.0 { // If the ingredient amount is over 0
                                    shoppingList.ingredients.append(tmpIngredient) // Add it again
                                }
                            }

                            if let removedIngredient = removedIngredient { // If it exists
                                let tmpIngredient = ingredient // Convert to var
                                tmpIngredient.amount -= removedIngredient.amount // Subtract the removed ingredients amount
                                shoppingList.ingredients.removeAll(where: { $0 == tmpIngredient }) // Remove it from the shoppingList
                                if tmpIngredient.amount > 0.0 { // If the ingredient amount is over 0
                                    shoppingList.ingredients.append(tmpIngredient) // Add it again
                                }
                            }
                        }
                        YKNetworkManager.ShoppingLists.update(shoppingList: shoppingList) // Update the shoppinglist
                    } else {
                        YKNetworkManager.ShoppingLists.update(shoppingList: ShoppingList(ownerId: refrigerator.ownerId, ingredients: [])) {
                            self.fixShoppingList(removed: removed, new: recipes)
                        }
                    }
                }
            }
        }
    }
}
