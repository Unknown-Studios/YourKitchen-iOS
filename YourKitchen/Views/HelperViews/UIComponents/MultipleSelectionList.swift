//
//  MultipleSelectionList.swift
//  YourKitchen
//
//  Created by Markus Moltke on 30/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct MultipleSelectionList: View {
    var items: [String]
    @Binding var selections: [String]

    var body: some View {
        List {
            ForEach(self.items, id: \.self) { item in
                MultipleSelectionRow(title: item, action:  {_ in
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }, isSelected: self.selections.contains(item))
            }
        }
    }
}
