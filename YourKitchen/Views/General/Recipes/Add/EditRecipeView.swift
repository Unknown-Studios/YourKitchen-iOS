//
//  EditRecipeView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 18/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ActionOver
import Kingfisher
import struct Kingfisher.KFImage
import SwiftUI

struct EditRecipeView: SwiftUI.View {
    @State var name: String = ""
    @State var description: String = ""
    @State var ingredients = [String: Ingredient]()
    @State var steps = [String]()
    @State var storedIngredients = [Ingredient]()
    @State var stepText: String = ""
    @State var image: UIImage?

    @State var imageSelected: Bool = false
    @State var showImagePicker: Bool = false
    @State var showTakePhoto: Bool = false
    @State var presented: Bool = false

    @State private var actionState: Int? = 0
    @State var clickable: Bool = true

    // DatePicker
    @State var time = Time(hour: 0, minute: 0)
    @State var showDatePicker = false

    // Type picker
    @State var selectedType: Cuisine = .american
    @State var recipeType: RecipeType = .main

    // Persons picker
    @State var selectedPersons: Int = 4
    var personsArray = [Int]()

    var recipe: Recipe

    @State var oldIngredient = Ingredient.none

    @Environment(\.presentationMode) var presentationMode

    init(recipe: Recipe) {
        self.recipe = recipe
        self._selectedPersons = State(wrappedValue: recipe.persons)
        self._name = State(wrappedValue: recipe.name)
        self._description = State(wrappedValue: recipe.description)
        var tmpIng = [String: Ingredient]()
        for ing in recipe.ingredients {
            tmpIng[ing.id] = ing
        }
        self._ingredients = State(wrappedValue: tmpIng)
        self._steps = State(wrappedValue: recipe.steps)
        self._time = State(wrappedValue: recipe.preparationTime)
        self._selectedType = State(wrappedValue: recipe.type)
        for i in 1 ..< 20 {
            personsArray.append(i)
        }
        getImage()
    }

    func getImage() {
        if self.recipe.image == "" {
            self.imageSelected = false
        } else if let image = recipe.image.url {
            self.imageSelected = true
            KingfisherManager.shared.downloader.downloadImage(with: image, completionHandler: { response in
                switch response {
                case let .success(result):
                    self.image = result.image
                case let .failure(err):
                    UserResponse.displayError(msg: err.localizedDescription)
                }
            })
        }
    }

    var body: some SwiftUI.View {
        _ = self.$actionState.onChange { state in
            self.oldIngredient = self.getIngredient(state ?? 1)
        }

        return Form {
            Section(header: Text("General")) {
                Text(self.name)
                LimitedTextField(entry: self.$description, placeholder: "Description", characterLimit: 150)
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
                }
                Picker(selection: self.$recipeType, label: Text("Select Type")) {
                    ForEach(RecipeType.allCases, id: \.self) { type in
                        Text(type.prettyName).tag(type)
                    }.navigationBarTitle(Text("Recipe Type"))
                }
                Picker(selection: self.$selectedPersons, label: Text("Select persons")) {
                    ForEach(self.personsArray, id: \.self) { person in
                        Text(person.description + (person == 1 ? " Person" : " Persons")).tag(person)
                    }.navigationBarTitle("Persons")
                }
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
            }
            Section(header: Text("Ingredients")) {
                List {
                    ForEach(self.ingredients.keys.sorted().indices, id: \.self) { key in
                        NavigationLink(destination: AmountSelection(oldIngredient: self.getIngredient(key), amountSelection: { (unit, amount) in
                            self.ingredients[self.oldIngredient.id]?.unit = unit
                            self.ingredients[self.oldIngredient.id]?.amount = amount
                        })) {
                            Text(self.getIngredient(key).description)
                        }.isDetailLink(false)
                    }
                    .onDelete(perform: deleteIngredient)
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
                    .onDelete(perform: deleteStep)
                    .onMove(perform: move)
                    YKTextField("Step description", text: self.$stepText, isFirstResponder: false, on: {
                        self.steps.append(self.stepText)
                        self.stepText = ""
                    }, type: .default)
                }
            }
            Button(action: {
                var ingredients = [Ingredient]()
                for (_, ingredient) in self.ingredients {
                    ingredients.append(ingredient)
                }
                YKNetworkManager.Users.get { user in
                    guard let user = user else { return }
                    let recipe = Recipe(id: self.recipe.id,
                                        name: self.name,
                                        description: self.description,
                                        type: self.selectedType,
                                        recipeType: self.recipeType,
                                        preparationTime: self.time,
                                        image: "",
                                        ingredients: ingredients,
                                        steps: self.steps,
                                        persons: self.selectedPersons,
                                        author: user)
                    YKNetworkManager.Recipes.update(recipe: recipe, image: self.image) { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
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
            guard YKNetworkManager.shared.currentUser != nil else {
                self.presentationMode.wrappedValue.dismiss()
                return
            }
            self.refreshStoredIngredients()
        }
    }

    private var ipadMacConfig = {
        IpadAndMacConfiguration(anchor: nil, arrowEdge: nil)
    }()

    func move(from source: IndexSet, to destination: Int) {
        self.steps.move(fromOffsets: source, toOffset: destination)
    }

    func getIngredient(_ key: Int) -> Ingredient {
        let arrIng = Array(self.ingredients)
        return arrIng[key].value
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

    func deleteStep(at offsets: IndexSet) {
        self.steps.remove(atOffsets: offsets)
    }

    func isValidRecipe() -> Bool {
        if self.name.isEmpty || self.description.isEmpty {
            return false
        }
        if self.time.hour == 0, self.time.minute == 0 {
            return false
        }
        if self.steps.count == 0 {
            return false
        }
        if !imageSelected {
            return false
        }
        if self.ingredients.count == 0 {
            return false
        }
        for (_, ingredient) in self.ingredients {
            if ingredient.name == "" || ingredient.name == "Unknown" {
                return false
            }
        }

        return true
    }

    func refreshStoredIngredients() {
        YKNetworkManager.Ingredients.get { ingredients in
            self.storedIngredients = ingredients
        }
    }
}

struct EditRecipeView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        EditRecipeView(recipe: Recipe.none)
    }
}
