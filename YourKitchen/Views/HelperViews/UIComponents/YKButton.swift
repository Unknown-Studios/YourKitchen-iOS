//
//  YKButton.swift
//  YourKitchen
//
//  Created by Markus Moltke on 26/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct YKButton: View {

    var action : () -> Void
    var text: String
    var image: Image?
    var backgroundColor: Color = AppConstants.Colors.YKColor

    @Environment(\.colorScheme) var colorScheme

    init(action : @escaping () -> Void, text: String, image: Image? = nil, backgroundColor: Color = AppConstants.Colors.YKColor) {
        self.action = action
        self.text = text
        self.image = image
        if backgroundColor == AppConstants.Colors.YKColor {
            if colorScheme == .dark {
                self.backgroundColor = Color.white
            } else {
                self.backgroundColor = Color.black
            }
        } else {
            self.backgroundColor = backgroundColor
        }
    }

    var body: some View {
        return Button(action: action) {
            HStack {
                self.image
                Text(self.text)
                    .frame(minWidth: 100.0, maxWidth: .infinity, maxHeight: 50.0)
                    .background(self.backgroundColor)
                    .foregroundColor(Color.white)
                    .cornerRadius(25.0)
                    .padding()
            }
        }
    }
}

struct YKButton_Previews: PreviewProvider {
    static var previews: some View {
        YKButton(action: {

        }, text: "Hey")
    }
}
