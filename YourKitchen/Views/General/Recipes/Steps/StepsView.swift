//
//  StepsView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct StepsView: View {
    @State private var currentPageIndex = 0
    @State private var offset: CGFloat = 0
    private let spacing: CGFloat = 25
    
    var recipe: Recipe
    var action: () -> Void
    
    init(recipe : Recipe, _ action: @escaping () -> Void) {
        self.recipe = recipe
        self.action = action //We need action because we can dismiss the recipe detail view on return then
    }

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            ModelPages(self.recipe.steps, currentPage: self.$currentPageIndex.onChange { val in
                print("New value: " + val.description)
            }, navigationOrientation: .horizontal, transitionStyle: .scroll) { idx, step in
                HStack {
                    StepView(step: step, stepNumber: idx + 1)
                    Spacer()
                }
            }
            ZStack {
                // PageControl(numberOfPages: self.steps.count, currentPage: self.$currentPageIndex)
                HStack {
                    if self.currentPageIndex > 0 {
                        Button(action: {
                            withAnimation {
                                self.currentPageIndex -= 1
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(Color.white)
                                .padding(8)
                                .frame(width: 30.0, height: 30.0)
                                .background(AppConstants.Colors.YKColor)
                                .cornerRadius(15.0)
                                .padding()
                        }
                    } else if #available(iOS 14.0, *) { //To make progress stay in place
                        Image(systemName: "arrow.left")
                            .foregroundColor(Color.clear)
                            .padding(8)
                            .frame(width: 30.0, height: 30.0)
                            .background(Color.clear)
                            .cornerRadius(15.0)
                            .padding()
                    }
                    if #available(iOS 14.0, *) {
                        ProgressView(value: self.progress)
                    } else {
                        Spacer()
                    }
                    if self.currentPageIndex + 1 < self.recipe.steps.count {
                        Button(action: {
                            withAnimation {
                                self.currentPageIndex += 1
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(Color.white)
                                .padding(8)
                                .frame(width: 30.0, height: 30.0)
                                .background(AppConstants.Colors.YKColor)
                                .cornerRadius(15.0)
                                .padding()
                        }
                    } else if self.currentPageIndex == self.recipe.steps.count - 1 {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                            self.action()
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.white)
                                .padding(8)
                                .frame(width: 30.0, height: 30.0)
                                .background(AppConstants.Colors.YKColor)
                                .cornerRadius(15.0)
                                .padding()
                        }
                    }
                }
            }
            Spacer()
        }.navigationBarTitle("Steps")
    }
    
    var progress : Double {
        return Double(self.currentPageIndex) / Double(self.recipe.steps.count - 1)
    }
}
