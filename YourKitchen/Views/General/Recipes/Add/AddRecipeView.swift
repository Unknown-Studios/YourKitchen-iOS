//
//  AddRecipe.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ActionOver
import SwiftUI

struct AddRecipeView: View {
    @State var name: String = ""
    @State var description: String = ""
    @State var ingredients = [String: Ingredient]()
    @State var steps = [String]()
    @State var recipes = [String: Recipe]()
    @State var storedIngredients = [Ingredient]()
    @State var storedRecipes = [Recipe]()
    @State var stepText: String = ""
    @State var image: UIImage?

    @State var imageSelected: Bool = false
    @State var showImagePicker: Bool = false
    @State var showTakePhoto: Bool = false
    @State var presented: Bool = false

    @State private var actionStateIngredient: Int? = 0
    @State private var actionStateRecipe: Int? = 0
    @State var clickable: Bool = true

    let completion: (Recipe) -> Void

    // DatePicker
    @State var time = Time(hour: 0, minute: 0)
    @State var showDatePicker = false

    // Type picker
    @State var selectedType: Cuisine = .american
    @State var recipeType: RecipeType = .main

    // Persons picker
    @State var selectedPerson: Int = 4
    var personsArray = [Int]()

    init(completion: @escaping (Recipe) -> Void) {
        self.completion = completion
        for i in 1 ..< 20 {
            personsArray.append(i)
        }
    }

    @State var oldIngredient = Ingredient.none
    @State var oldRecipe = Recipe.none

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        Form {
            Section(content: {
                YKTextField("Name", text: self.$name)
                YKTextField("Description", text: self.$description)
                Button(action: {
                    self.showDatePicker = !self.showDatePicker
                }) {
                    HStack {
                        Text("Select preparation time")
                        Spacer()
                        Text(self.time.description)
                            .foregroundColor(Color.primary)
                    }
                }
                if self.showDatePicker {
                    YKDatePicker(time: self.$time)
                }
                Picker(selection: self.$selectedType, label: Text("Select Cuisine")) {
                    ForEach(Cuisine.allCases, id: \.self) { type in
                        Text(type.prettyName).tag(type)
                    }.navigationBarTitle(Text("Cuisine"))
                }.navigationBarTitle("Add Recipe")
                Picker(selection: self.$recipeType, label: Text("Select Type")) {
                    ForEach(RecipeType.allCases, id: \.self) { type in
                        Text(type.prettyName).tag(type)
                    }.navigationBarTitle(Text("Recipe Type"))
                }.navigationBarTitle("Add Recipe")
                Picker(selection: self.$selectedPerson, label: Text("Select persons")) {
                    ForEach(self.personsArray, id: \.self) { person in
                        Text(person.description + (person == 1 ? " Person" : " Persons")).tag(person)
                    }.navigationBarTitle("Persons")
                }.navigationBarTitle("Add Recipe")
                Button(action: {
                    self.presented = true
                }) {
                    if self.imageSelected {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Image select")
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                            Text("Select an image")
                        }
                    }
                }
                .actionOver(
                    presented: $presented,
                    title: "Image Picker",
                    message: nil,
                    buttons: [
                        ActionOverButton(
                            title: "Take Photo",
                            type: .normal,
                            action: {
                                self.showTakePhoto = true
                            }
                        ),
                        ActionOverButton(
                            title: "Select Photo",
                            type: .normal,
                            action: {
                                self.showImagePicker = true
                            }
                        ),
                        ActionOverButton(
                            title: nil,
                            type: .cancel,
                            action: nil
                        )
                    ],
                    ipadAndMacConfiguration: ipadMacConfig
                )
            }).navigationBarTitle("Add Recipe")
            Section(header: Text("Ingredients")) {
                List {
                    ForEach(self.ingredients.keys.sorted().indices, id: \.self) { key in
                        NavigationLink(destination: IngredientList(
                            itemClicked: { (newIngredient, newRecipe) in
                                self.ingredients[oldIngredient.id] = nil
                                if let newIngredient = newIngredient {
                                    self.ingredients[newIngredient.id] = newIngredient
                                } else if let newRecipe = newRecipe {
                                    self.recipes[newRecipe.id] = newRecipe
                                }
                            }, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes),
                        tag: key + 1, selection: self.$actionStateIngredient.onChange { state in
                            print((state?.description ?? "") + " state changed")
                            self.oldIngredient = self.getIngredient((state ?? 1) - 1)
                        }) {
                            Text(self.getIngredient(key).description)
                        }.isDetailLink(false)
                    }
                    .onDelete(perform: deleteIngredient)
                    ForEach(self.recipes.keys.sorted().indices, id: \.self) { (key) in
                        NavigationLink(
                            destination: IngredientList(
                                itemClicked: { (newIngredient, newRecipe) in
                                    //If we are selecting something instead of a recipe we should still remove it from the recipe table
                                    self.recipes[oldRecipe.id] = nil
                                    if let newIngredient = newIngredient {
                                        self.ingredients[newIngredient.id] = newIngredient
                                    } else if let newRecipe = newRecipe {
                                        self.recipes[newRecipe.id] = newRecipe
                                    }
                            }, storedIngredients: self.$storedIngredients, storedRecipes: self.$storedRecipes), tag: key + 1001, //Add 1001 so the navigations don't collapse.
                            selection: self.$actionStateRecipe.onChange { state in
                                self.oldRecipe = self.getRecipe((state ?? 1) - 1)
                            },
                            label: {
                                Text(self.getRecipe(key).name)
                            })
                    }
                    Button(action: {
                        print("Adding ingredient..")
                        if let user = YKNetworkManager.shared.currentUser {
                            let i = Ingredient(name: "Unknown", units: [""], ownerId: user.id, type: .meat)
                            self.ingredients[i.id] = i
                        }
                    }) {
                        Text("Add ingredient")
                    }
                }
            }
            Section(header: Text("Steps")) {
                List {
                    ForEach(self.steps.indices, id: \.self) { step in
                        TextField("Step", text: Binding<String>(
                            get: {
                                if step < self.steps.count {
                                    return self.steps[step]
                                } else {
                                    return ""
                                }
                            }, set: { self.steps[step] = $0 }
                        ),
                        onCommit: {
                            self.steps.removeAll(where: { $0 == "" })
                        })
                    }
                    .onDelete { offsets in
                        self.steps.remove(atOffsets: offsets)
                    }
                    .onMove(perform: move)
                    TextField("Step name", text: self.$stepText, onCommit: {
                        self.steps.append(self.stepText)
                        self.stepText = ""
                    })
                }
            }
            Button(action: {
                var ingredients = [Ingredient]()
                for (_, ingredient) in self.ingredients {
                    ingredients.append(ingredient)
                }
                YKNetworkManager.Users.get { user in
                    guard let user = user else { return }
                    let recipe = Recipe(id: UUID().uuidString,
                                        name: self.name,
                                        description: self.description,
                                        type: self.selectedType,
                                        recipeType: self.recipeType,
                                        preparationTime: self.time,
                                        image: "",
                                        ingredients: ingredients,
                                        steps: self.steps,
                                        author: user)
                    YKNetworkManager.Recipes.add(recipe: recipe, self.image) { recipe in
                        self.completion(recipe)
                    }
                }
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            }.disabled(!isValidRecipe())
            Section(header: Text("")) {
                EmptyView()
            }.keyboardAwarePadding()
        }
        .sheet(isPresented: self.showImagePicker ? self.$showImagePicker : self.$showTakePhoto) {
            if self.showImagePicker {
                YKImagePicker(image: self.$image) {
                    self.imageSelected = true
                }
            } else if self.showTakePhoto {
                YKTakePhoto(image: self.$image) {
                    self.imageSelected = true
                }
            } else {
                EmptyView()
            }
        }
        .navigationBarItems(trailing: EditButton())
        .navigationBarTitle("Add Recipe")
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.refreshStoredIngredients()
        }
    }

    private var ipadMacConfig = {
        IpadAndMacConfiguration(anchor: nil, arrowEdge: nil)
    }()

    func move(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
    }

    func getIngredient(_ key: Int) -> Ingredient {
        if (ingredients.count <= key) {
            print("Couldn't find ingredient with index: " + key.description)
            return Ingredient.none
        }
        let arrIng = Array(ingredients)
        return arrIng[key].value
    }
    
    func getRecipe(_ key: Int) -> Recipe {
        let arrRecipe = Array(recipes)
        return arrRecipe[key].value
    }

    func deleteIngredient(at offsets: IndexSet) {
        var curI = 0
        offsets.forEach { i in
            for (k, _) in self.ingredients {
                if curI == i {
                    self.ingredients[k] = nil
                    break
                }
                curI += 1
            }
        }
    }

    func isValidRecipe() -> Bool {
        if name.isEmpty || description.isEmpty {
            return false
        }
        if time.hour == 0 && time.minute == 0 {
            return false
        }
        if steps.count == 0 {
            return false
        }
        if image == nil {
            return false
        }
        if ingredients.count == 0 {
            return false
        }
        for (_, ingredient) in ingredients {
            if ingredient.name == "" || ingredient.name == "Unknown" {
                return false
            }
        }

        return true
    }

    func refreshStoredIngredients() {
        YKNetworkManager.Ingredients.get { ingredients in
            YKNetworkManager.Recipes.getAll { recipes in
                self.storedIngredients = ingredients
                let ingredientsRecipes = recipes.filter { $0.recipeType == .ingredient }
                self.storedRecipes.append(contentsOf: ingredientsRecipes) //Recipe meant as ingredients
            }
        }
    }
}
