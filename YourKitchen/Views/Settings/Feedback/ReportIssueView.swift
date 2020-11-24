//
//  ReportIssueView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 14/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct ReportIssueView: View {
    
    @State var anonymize = false
    @State var text = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Please share your issues with us and let us know how to improve.")
                .font(.title)
                .lineLimit(2)
                MultilineTextView(placeholder: "Write the issue here", text: self.$text)
            
            if (YKNetworkManager.shared.currentUser != nil) {
                Toggle(isOn: self.$anonymize) {
                    Text("Anonymize")
                }.padding(.vertical)
            }
            Button(action: {
                YKNetworkManager.Feedback.sendIssue(self.text, anonymize: self.anonymize) {
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

struct ReportIssueView_Previews: PreviewProvider {
    static var previews: some View {
        ReportIssueView()
    }
}
