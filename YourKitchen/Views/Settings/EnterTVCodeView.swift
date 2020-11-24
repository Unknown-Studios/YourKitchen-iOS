//
//  EnterTVCodeView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 21/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import Alamofire


struct EnterTVCodeView: View {
    
    @State var code : String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Enter the code being shown on your TV")
            HStack {
                Spacer()
                LimitedCodeTextField(entry: self.$code)
                Spacer()
            }
            Button(action: {
                self.handleCode()
            }) {
                Text("Done")
            }
        }.navigationBarTitle("Enter Code")
    }
    
    func handleCode() {
        if (code.count < 6) {
            UserResponse.displayError(msg: "You need to input 6 numbers")
            return
        }
        guard let user = YKNetworkManager.shared.currentUser else { return }
        let email = user.email
        AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/handleCode?email=" + email + "&code=" + self.code)
            .validate(statusCode: 200..<300)
            .responseString { (result) in
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EnterTVCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterTVCodeView()
    }
}
