//
//  LimitedTextField.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct LimitedTextField: View {
    @Binding var entry: String
    var placeholder: String
    let characterLimit: Int

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            TextField(self.placeholder, text: $entry)
                .fixedSize()
                .disabled(entry.count > (characterLimit - 1))
        }
    }
}
