//
//  SendFeedbackView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 14/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct SendFeedbackView: View {
    
    @State var anonymize = false
    @State var text = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Please share your comments and suggestions with us.")
                .font(.system(size: 25.0))
                .lineLimit(2)
            
            MultilineTextView(placeholder: "Your Feedback", text: self.$text)
            
            //Feedback is automatically anonymized when no user is found
            if (YKNetworkManager.shared.currentUser != nil) {
                Toggle(isOn: self.$anonymize) {
                    Text("Anonymize")
                }.padding(.vertical)
            }
            Button(action: {
                YKNetworkManager.Feedback.sendFeedback(self.text, anonymize: self.anonymize) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Submit")
                .foregroundColor(Color.white)
                .frame(width: 280, height: 45)
                .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
            }
            Spacer()
        }.keyboardAwarePadding()
        .navigationBarTitle("Send Feedback")
        .padding()
    }
}

struct SendFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        SendFeedbackView()
    }
}
