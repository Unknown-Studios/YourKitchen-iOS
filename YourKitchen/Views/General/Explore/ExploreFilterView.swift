//
//  ExploreFilterView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 30/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct ExploreFilterView: View {
    
    @Binding var recipes : [Recipe]
    @Binding var selectedVeganType : Int
    @Binding var prepUnder30 : Bool
    @Binding var ingredientsCount : Double
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Picker(selection: self.$selectedVeganType, label: Text("")) {
                Text("None").tag(0)
                Text("Vegetarian").tag(1)
                Text("Vegan").tag(2)
            }.pickerStyle(SegmentedPickerStyle())
            Toggle(isOn: self.$prepUnder30) {
                Text("Under 30 min.")
            }
            Text("Max ingredients: " + Int(self.ingredientsCount).description)
            Slider(value: self.$ingredientsCount, in: 5...100, step: 1)
            Spacer()
        }.navigationBarTitle("Filters", displayMode: .large)
        .navigationBarItems(trailing: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done")
        }))
    }
}
