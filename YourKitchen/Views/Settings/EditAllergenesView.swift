//
//  EditAllergenesView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 30/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import Firebase

struct EditAllergenesView: View {
    
    @State var selections : [String]
    
    init() {
        if let user = YKNetworkManager.shared.currentUser {
            self._selections = State(wrappedValue: user.allergenes.map({ $0.prettyName }))
        } else {
            self._selections = State(wrappedValue: [])
        }
    }
    
    var body: some View {
        VStack {
            MultipleSelectionList(items: Allergen.all, selections: self.$selections)
            .navigationBarTitle("Select Allergenes")
        }.onDisappear {
            YKNetworkManager.Users.update(array: ["allergenes": self.selections])
        }
    }
}

struct EditAllergenesView_Previews: PreviewProvider {
    static var previews: some View {
        EditAllergenesView()
    }
}
