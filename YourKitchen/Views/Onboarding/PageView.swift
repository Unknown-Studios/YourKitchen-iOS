//
//  PageView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 24/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct PageView: View {
    var title: String = "YourKitchen"
    var header: String
    var content: String
    var textColor: Color = Color.white

    let textWidth: CGFloat = 350

    var body: some View {
        return
            VStack(alignment: .center, spacing: 50) {
                Text(title)
                    .font(Font.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .frame(width: textWidth)
                    .multilineTextAlignment(.center)
                VStack(alignment: .center, spacing: 5) {
                    Text(header)
                        .font(Font.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text(content)
                        .font(Font.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                }
            }.padding(60)
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(header: "Feed", content: "Personalize your own feed")
    }
}
