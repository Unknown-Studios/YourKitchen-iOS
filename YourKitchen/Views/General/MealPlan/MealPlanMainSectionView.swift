//
//  MealPlanMainSectionView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 23/09/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

/* struct MealPlanMainSectionView: View {

     @ObservedObject var mealplanWrapper : MealplanWrapper
     var updatedMealplan : (Date, Recipe) -> ()
     @State var refreshed = false

     var body: some View {
         Section(header: Text("Meal Plan")) {
             ForEach(self.mealplanWrapper.mealplan.mealplan.meals.indices, id: \.self) { (idx) in
                 VStack {
                     if (self.getItem(idx).wrappedValue.recipe.id == "none") {
                         AnyView(NavigationLink(destination: SelectRecipeView(recipe: self.getItem(idx).recipe)) {
                             MealplanRow(meal: self.refreshed ? self.getItem(idx) : self.getItem(idx))
                         }.onAppear()   // <--- this makes it work
                         .onReceive(self.mealplanWrapper.$mealplan) { (_) in
                             print("Updated mealplan wrapper")
                             self.refreshed.toggle()
                         })
                     } else {
                         AnyView(NavigationLink(destination: RecipeDetailView(recipe: self.getItem(idx).recipe, weekday: self.getItem(idx).date, completion: self.updatedMealplan)) {
                             MealplanRow(meal: self.refreshed ? self.getItem(idx) : self.getItem(idx))
                         }.onAppear()   // <--- this makes it work
                         .onReceive(self.mealplanWrapper.$mealplan) { (_) in
                             print("Updated mealplan wrapper")
                             self.refreshed.toggle()
                         })
                     }
                 }
             }
             /* ForEach(self.mealplanWrapper.mealplan.mealplan.meals.indices, id: \.self) { (index) in
                 (self.getItem(index).1.id.wrappedValue == "none") ?
                     AnyView(NavigationLink(destination: SelectRecipeView(completion: self.updatedMealplan, date: self.getItem(index).0)) {
                         MealplanRow(date: self.getItem(index).0,
                                     recipe: self.getItem(index).1)
                     }) : AnyView(NavigationLink(destination: RecipeDetailView(recipe: self.getItem(index).1.wrappedValue, weekday: self.getItem(index).0.wrappedValue, completion: self.updatedMealplan)) {
                     MealplanRow(date: self.getItem(index).0, recipe: self.getItem(index).1)
                 })
             } */
         }
     }

     func getItem(_ index : Int) -> Binding<Meal> {
         return self.$mealplanWrapper.mealplan.mealplan.meals[index]
     }
 }
 */
