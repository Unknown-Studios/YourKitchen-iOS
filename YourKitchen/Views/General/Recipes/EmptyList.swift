//
//  EmptyList.swift
//  YourKitchen
//
//  Created by Markus Moltke on 11/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FASwiftUI
import SwiftUI

struct EmptyList: View {
    var body: some View {
        Group {
            Spacer()
            FAText(iconName: "sad-tear", size: 50)
                .padding()
            Text("Nothing here yet..")
            Spacer()
        }
    }
}

struct EmptyList_Previews: PreviewProvider {
    static var previews: some View {
        EmptyList()
    }
}
