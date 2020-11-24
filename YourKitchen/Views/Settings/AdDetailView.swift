//
//  AdDetailView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 14/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct AdDetailView: View {
    
    @State var accepted = UserDefaults.standard.bool(forKey: "adConsent")
    
    var body: some View {
        Form {
            Toggle(isOn: self.$accepted.onChange({ (value) in
                print("Ad consent changed")
                UserDefaults.standard.set(value, forKey: "adConsent")
                YKNetworkManager.Users.update(array: ["adConsent": value])
            })) {
                Text("Should your ads be tailored?")
            }
        }.navigationBarTitle("Ads")
    }
}

struct AdDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AdDetailView()
    }
}
