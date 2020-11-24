//
//  ShareButton.swift
//  YourKitchen
//
//  Created by Markus Moltke on 04/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct ShareButton<Content: View>: View {

    var action : () -> Void
    let image: Content
    let title: String
    var backgroundColor: Color

    var body: some View {
        return VStack {
            Button(action: self.action) {
                VStack {
                    self.image
                        .frame(width: 50.0, height: 50.0)
                        .background(Circle().fill(backgroundColor))
                        .padding(6.0)
                    Text(self.title)
                        .foregroundColor(Color.secondary)
                        .font(.system(size: 12.0))
                    Spacer()
                }
            }.buttonStyle(PlainButtonStyle())
            Spacer()
        }.frame(width: 70.0, height: 75.0)
    }
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        ShareButton(action: {
            print("Clicked")
        }, image: Image(systemName: "ellipsis"), title: "Other", backgroundColor: Color.orange)
    }
}
