//
//  RecipeDetailView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 28/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FASwiftUI
import Firebase
import Kingfisher
import struct Kingfisher.KFImage
import SwiftUI

enum RatingType {
    case like
    case dislike
}

struct RecipeDetailView: SwiftUI.View {
    // @ObservedObject var recipeWrapper : RecipeWrapper

    @State var recipe: Recipe
    @State var weekday: Date
    var completion: ((Date, Recipe) -> Void)?
    @State var rating = 0
    @State var loading = false

    @State var votedThumbsdown = false
    @State var votedThumbsup = false
    @State var showDeletePrompt = false

    var viewModel = MealplanViewModel()

    // Person picker
    @State var selectedPersons: Int = 4
    var personsArray = [Int]()

    init(recipe: Recipe, weekday: Date = Date(), completion: ((Date, Recipe) -> Void)? = nil) {
        self._recipe = State(initialValue: recipe)
        self._weekday = State(initialValue: weekday)
        self.completion = completion
        self._selectedPersons = State(initialValue: YKNetworkManager.shared.currentUser?.defaultPersons ?? recipe.persons)
        self.rating = recipe.rating
    }

    // Environment
    @Environment(\.presentationMode) var presentationMode

    var body: some SwiftUI.View {
        LoadingView(title: nil, loading: self.$loading) {
            ScrollView {
                GeometryReader { geometry in
                    ZStack {
                        if geometry.frame(in: .global).minY <= 0 {
                            self.recipeImage
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .offset(y: geometry.frame(in: .global).minY / 9)
                                .clipped()
                        } else {
                            self.recipeImage
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height + geometry.frame(in: .global).minY)
                                .clipped()
                                .offset(y: -geometry.frame(in: .global).minY)
                        }
                    }
                }.frame(height: 300)

                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(self.recipe.name)
                                .font(.system(size: 30.0)).bold()
                            if completion != nil {
                                Text(self.weekday.dateString)
                                    .font(.system(size: 16.0)).bold()
                                    .foregroundColor(Color.white)
                                    .padding(3.0)
                                    .padding(.horizontal, 6.0)
                                    .background(RoundedRectangle(cornerRadius: 12.0)
                                        .fill(Color.green))
                                        .padding(.vertical, 6.0)
                            }
                        }
                        NavigationLink(destination: UserDetailView(user: self.recipe.author)) {
                            HStack {
                                VStack {
                                    KFImage(self.recipe.author.image.url, options: [
                                        .transition(.fade(0.5))
                                    ])
                                        .placeholder {
                                            Image("UserImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        }
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60.0, height: 60.0)
                                        .cornerRadius(30.0)
                                        .clipped()
                                    Spacer()
                                }

                                VStack(alignment: .leading) {
                                    Text(self.recipe.author.name)
                                        .bold()
                                        .padding(8)
                                    Spacer()
                                }
                            }
                        }.frame(height: 80.0)
                        .buttonStyle(PlainButtonStyle())
                        Text(self.recipe.description)
                            .lineLimit(4)
                    }
                    Spacer()
                }.padding()
                VStack {
                    likedView
                    Group {
                        VStack {
                            WrappedLayout(platforms: .constant([self.recipe.dateAdded.dateTimeString, "Time: " + self.recipe.preparationTime.description, "Steps: " + self.recipe.steps.count.description, "Ingredients: " + self.recipe.ingredients.count.description, "Persons: " + self.recipe.persons.description,
                                                                self.recipe.type.prettyName]))
                        }.padding()
                    }
                    if !premium {
                        GADBannerViewController().frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                    }
                    Group {
                        LabelledDivider(label: "Ingredients")
                        NavigationLink(destination: SelectPersonsView(selectPerson: self.$selectedPersons)) {
                            HStack {
                                Text("Persons")
                                Spacer()
                                Text(self.selectedPersons.description + (self.selectedPersons == 1 ? " Person" : " Persons"))
                                    .foregroundColor(Color.secondary)
                            }.padding()
                        }
                        ForEach(self.recipe.ingredients, id: \.self) { ingredient in
                            YKRow(leftText: String(format: "%.0f", (Double(ingredient.amount) * (Double(self.selectedPersons) / Double(recipe.persons)))) + ingredient.unit, rightText: ingredient.name)
                        }
                        ForEach(self.recipe.recipes, id: \.self) { (recipe) in
                            NavigationLink(
                                destination: RecipeDetailView(recipe: recipe),
                                label: {
                                    YKRow(leftText: "R", rightText: recipe.name)
                                })
                        }
                    }
                    Group {
                        LabelledDivider(label: "Actions")
                        Button(action: {
                            self.addToShoppingList()
                        }) {
                            Text("Add to Shopping List")
                                .foregroundColor(Color.white)
                                .frame(width: 280, height: 45)
                                .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
                        }
                        .padding()
                        if self.completion != nil {
                            NavigationLink(destination: SelectRecipeView(completion: { date, recipe in
                                if let completion = self.completion {
                                    self.recipe = recipe
                                    completion(date, recipe)
                                }
                            }, date: self.weekday)) {
                                Text("Select another recipe")
                                    .foregroundColor(Color.white)
                                    .frame(width: 280, height: 45)
                                    .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
                            }.buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                        if isOwner() {
                            NavigationLink(destination: EditRecipeView(recipe: self.recipe)) {
                                Text("Edit Recipe")
                                    .foregroundColor(Color.white)
                                    .frame(width: 280, height: 45)
                                    .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
                            }.buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                        NavigationLink(destination: StepsView(recipe: self.recipe) {
                            YKNetworkManager.Interests.update(likes: [self.recipe.type.caseName: 1])
                            self.viewModel.updateMadeThis(recipe: self.recipe)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Start Cooking")
                                .foregroundColor(Color.white)
                                .frame(width: 280, height: 45)
                                .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
                        }.buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                    Group {
                        LabelledDivider(label: "Share")
                        ShareButtons(recipe: self.$recipe)
                    }
                }.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 75)
            }
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                self.getRating()
                self.getRecipe()
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: "Recipe Detail",
                                                AnalyticsParameterScreenClass: RecipeDetailView.self])
            }
        }
        .navigationBarTitle("", displayMode: .large)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "chevron.left")
                .foregroundColor(Color.white)
                .imageScale(.large)
                .background(Circle().fill(AppConstants.Colors.YKColor.opacity(0.75)).frame(width: 35, height: 35))
                .padding()
        }), trailing: isOwner() ? AnyView(VStack {
            deleteButton
        }) : AnyView(EmptyView()))
        .alert(isPresented: self.$showDeletePrompt) { () -> Alert in
            Alert(title: Text("Are you sure?"),
                  message: Text("Are you sure you want to delete this recipe?"),
                  primaryButton: .default(Text("No"),
                                          action: {
                                              self.showDeletePrompt = false
                                          }),
                  secondaryButton: .destructive(Text("Yes"),
                                                action: {
                                                    self.showDeletePrompt = false
                                                    YKNetworkManager.Recipes.delete(recipeId: self.recipe.id) {
                                                        self.presentationMode.wrappedValue.dismiss()
                                                    }
                                                }))
        }
    }

    // The recipe image
    var recipeImage: some SwiftUI.View {
        KFImage(self.recipe.image.url)
            .resizable()
            .placeholder {
                Image("Placeholder")
            }
            .cancelOnDisappear(true)
    }

    @ViewBuilder var likedView: some SwiftUI.View {
        HStack {
            self.likeButton(type: .dislike)
            Text(self.rating.description)
                .foregroundColor(self.rating == 0 ? Color.primary : Color.white)
                .frame(width: 40.0, height: 40.0, alignment: .center)
                .background(Circle().fill(self.rating > 0 ? Color.green : (self.rating < 0 ? Color.red : Color.clear)))
                .overlay(
            Circle().stroke(self.rating == 0 ? Color.primary : Color.clear, lineWidth: 2))
            self.likeButton(type: .like)
        }
    }

    func addToShoppingList() {
        guard let user = YKNetworkManager.shared.currentUser else { return }
        self.loading = true
        YKNetworkManager.ShoppingLists.get(user.id) { (shoppinglist) in
            guard let shoppinglist = shoppinglist else {
                UserResponse.displayError(msg: "Couldn't get shoppinglist")
                return
            }
            var tmpIngredients = shoppinglist.ingredients
            for ingredient in self.recipe.ingredients {
                if let ing = tmpIngredients.first(where: { $0.id == ingredient.id }) {
                    ingredient.amount += ing.amount
                    tmpIngredients.removeAll(where: { $0.id == ingredient.id })
                }
                tmpIngredients.append(ingredient)
            }
            var tmpShoppinglist = shoppinglist
            tmpShoppinglist.ingredients = tmpIngredients
            YKNetworkManager.ShoppingLists.update(shoppingList: tmpShoppinglist, {
                self.presentationMode.wrappedValue.dismiss()
                self.loading = true
            })
        }
    }

    func likeButton(type: RatingType) -> some SwiftUI.View {
        if (!isOwner()) {
            let voted: Bool = type == .like ? self.votedThumbsup : self.votedThumbsdown
            let color: SwiftUI.Color = type == .like ? Color.green : Color.red
            var imageString = ""
            if type == .like {
                imageString = voted ? "hand.thumbsup.fill" : "hand.thumbsup"
            } else {
                imageString = voted ? "hand.thumbsdown.fill" : "hand.thumbsdown"
            }
            return AnyView(Button(action: {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                self.handleRating(type: type)
            }) {
                Image(systemName: imageString)
                    .font(.system(size: 25.0))
            }.buttonStyle(PlainButtonStyle())
                .foregroundColor(voted ? Color.white : Color.primary)
                .frame(width: 40.0, height: 40.0, alignment: .center)
                .background(Circle().fill(voted ? color : Color.clear))
                .padding(.horizontal, 8))
        } else {
            return AnyView(EmptyView())
        }
    }

    // Delete recipe
    var deleteButton: some SwiftUI.View {
        Button(action: {
            self.showDeletePrompt = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(Color.white)
                .imageScale(.medium)
                .background(Circle().fill(AppConstants.Colors.YKColor.opacity(0.75)).frame(width: 35, height: 35))
                .padding()
        }
    }

    func isOwner() -> Bool {
        self.recipe.author == YKNetworkManager.shared.currentUser
    }

    func getRecipe() {
        YKNetworkManager.Recipes.get(id: self.recipe.id) { newRecipe in
            self.recipe = newRecipe
            self.rating = recipe.rating
        }
    }

    func getRating() {
        YKNetworkManager.Ratings.get(recipe: self.recipe) { rating in
            if rating == -1 {
                self.votedThumbsdown = true
            } else if rating == 1 {
                self.votedThumbsup = true
            }
        }
    }

    func handleRating(type: RatingType) {
        let rating = type == .like ? 1 : -1
        switch type {
        case .dislike:
            self.votedThumbsdown = !self.votedThumbsdown
            self.votedThumbsup = false
            YKNetworkManager.Ratings.update(rating: self.votedThumbsdown ? -1 : 0, recipe: self.recipe)
            self.rating += self.votedThumbsdown ? -1 : 1
        case .like:
            self.votedThumbsdown = false
            self.votedThumbsup = !self.votedThumbsup
            YKNetworkManager.Ratings.update(rating: self.votedThumbsup ? 1 : 0, recipe: self.recipe)
            self.rating += self.votedThumbsup ? 1 : -1
        }
        YKNetworkManager.Interests.update(ratings: [self.recipe.type.caseName: rating])
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
