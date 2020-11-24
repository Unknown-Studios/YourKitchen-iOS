//
//  TestView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 01/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ASCollectionView
import SwiftUI

struct TestView: View {
    @State var steps = [Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none), Recipe(name: "Hey", description: "ok", type: .italian, recipeType: .main, preparationTime: Time(hour: 1, minute: 1), image: "", ingredients: [], steps: [], author: YKUser.none)]

    var body: some View {
        VStack {
            ASCollectionView(data: self.steps, dataID: \.self) { item, _ in
                UserRecipeRow(recipe: item)
            }.layout(self.layout)
        }
    }

    var random: Bool {
        Int.random(in: 0 ..< 10) == 5
    }
}

extension TestView {
    var layout: ASCollectionLayout<Int> {
        ASCollectionLayout(scrollDirection: .vertical, interSectionSpacing: 0) {
            ASCollectionLayoutSection {
                let gridBlockSize = NSCollectionLayoutDimension.fractionalWidth(1 / CGFloat(2))
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: gridBlockSize,
                        heightDimension: .fractionalHeight(1.0)
                    ))
                let inset = CGFloat(1)
                item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

                let itemsGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: gridBlockSize
                    ),
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: itemsGroup)
                return section
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
