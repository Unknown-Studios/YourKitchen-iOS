//
//  StepView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 12/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct StepView: View {
    var step: String
    var stepNumber: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step " + self.stepNumber.description)
                .font(.title)
                .bold()
            Text(step)
                .font(.subheadline)
                .lineLimit(nil)
            Spacer()
        }.padding()
    }
}
