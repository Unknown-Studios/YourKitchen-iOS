//
//  SelectPersonsView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 18/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct SelectPersonsView: View {
    
    @Binding var selectPerson : Int
    var personsArray = [Int]()
    
    init(selectPerson : Binding<Int>) {
        self._selectPerson = selectPerson
        for i in 1..<20 {
            personsArray.append(i)
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(self.personsArray, id: \.self) { (item) in
                Button(action: {
                    self.selectPerson = item
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(item.description + (item == 1 ? " Person" : " Persons"))
                        Spacer()
                        self.checkmark(item: item)
                    }
                }
            }.navigationBarTitle("Persons")
        }
    }
    
    func checkmark(item : Int) -> some View {
        if (item == self.selectPerson) {
            return AnyView(Image(systemName: "checkmark"))
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct SelectPersonsView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPersonsView(selectPerson: .constant(4))
    }
}
