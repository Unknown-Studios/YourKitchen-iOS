//
//  HighPriorityButtonStyle.swift
//  YourKitchen
//
//  Created by Markus Moltke on 03/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct HighPriorityButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        MyButton(configuration: configuration)
    }

    private struct MyButton: View {
        @State var pressed = false
        let configuration: PrimitiveButtonStyle.Configuration

        var body: some View {
            let gesture = DragGesture(minimumDistance: 0)
                .onChanged { _ in self.pressed = true }
                .onEnded { _ in
                    self.pressed = false
                    self.configuration.trigger()
                }

            return configuration.label
                .opacity(pressed ? 0.5 : 1.0)
                .highPriorityGesture(gesture)
        }
    }
}
