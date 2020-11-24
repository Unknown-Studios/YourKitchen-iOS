//
//  LimitedTextField.swift
//  YourKitchen
//
//  Created by Markus Moltke on 21/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct LimitedCodeTextField: View {
    @Binding var entry: String

    let characterLimit = 6

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        YKTextField("6-digit Code", text: $entry, isFirstResponder: true, type: .numberPad)
            .font(.title)
            .multilineTextAlignment(.center)
            .padding()
            .frame(width: 120, height: 45)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
            .disabled(entry.count > (characterLimit - 1))
    }
}
