//
//  SelectCategoryView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 17/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct SelectCategoryView: View {
    
    @Binding var selectedCategory : Int
    @Binding var recipes : [Recipe]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: {
                    self.selectedCategory = 0
                }) {
                    VStack {
                        Text("All")
                            .bold()
                            .foregroundColor(self.selectedCategory == 0 ? Color.primary : Color.secondary)
                            .padding(0)
                            Rectangle().fill(self.selectedCategory == 0 ? AppConstants.Colors.YKColor : Color.clear)
                                .frame(height: 4)
                                .padding(.horizontal, 4)
                    }.fixedSize(horizontal: true, vertical: true)
                }
                .padding(.horizontal, 8)
                ForEachWithIndex(Cuisine.allCases, id: \.self) { (index, item) in
                    Button(action: {
                        self.selectedCategory = (index + 1)
                    }) {
                        VStack {
                            Text(self.getName(item))
                                .bold()
                                .foregroundColor(self.isSelected(index) ? Color.primary : Color.secondary)
                                .padding(0)
                                Rectangle().fill(self.isSelected(index) ? AppConstants.Colors.YKColor : Color.clear)
                                    .frame(height: 4)
                                    .padding(.horizontal, 4)
                        }.fixedSize(horizontal: true, vertical: true)
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
    }
    
    func getName(_ type : Cuisine) -> String {
        return type.prettyName
    }
    
    func isSelected(_ index : Int) -> Bool {
        return self.selectedCategory == (index + 1)
    }
}

struct SelectCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCategoryView(selectedCategory: .constant(0), recipes: .constant([Recipe.none]))
    }
}
