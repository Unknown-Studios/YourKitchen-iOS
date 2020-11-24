//
//  YKRow.swift
//  YourKitchen
//
//  Created by Markus Moltke on 29/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct YKRow: View {
    var leftText: String
    var rightText: String

    var body: some View {
        HStack {
            Text(leftText)
            Divider()
            Text(rightText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }.padding()
            .frame(minHeight: 35.0)
    }
}

struct YKRow_Previews: PreviewProvider {
    static var previews: some View {
        YKRow(leftText: "left", rightText: "right")
    }
}
