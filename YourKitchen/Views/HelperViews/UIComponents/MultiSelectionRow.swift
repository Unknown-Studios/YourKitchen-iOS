//
//  MultiSelectionRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 29/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct MultipleSelectionRow: View {
    var title: String
    var action: (Bool) -> Void
    @State var isSelected: Bool = false

    var body: some View {
        Button(action: {
            self.isSelected = !self.isSelected
            self.action(self.isSelected)
        }) {
            HStack {
                Text(self.title)
                    .foregroundColor(Color.primary)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
