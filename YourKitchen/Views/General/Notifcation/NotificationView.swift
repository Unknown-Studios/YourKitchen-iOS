//
//  NotificationView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FASwiftUI
import SwiftUI

struct NotificationView: View {
    @Binding var notifications: [YKNotification]
    @State var selectNotification: YKNotification?
    @State var presentAcceptDeny = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                if notifications.count == 0 {
                    Spacer()
                    FAText(iconName: "cookie-bite", size: 50.0)
                        .padding()
                    Text("No notifications..")
                    Spacer()
                } else {
                    List {
                        ForEach(self.notifications) { notification in
                            Button(action: {
                                self.handleNotification(notification)
                            }) {
                                VStack {
                                    HStack {
                                        Text(notification.title).bold()
                                        Spacer()
                                    }
                                    HStack {
                                        Text(notification.message).lineLimit(nil)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        Text("")
                            .actionSheet(isPresented: self.$presentAcceptDeny) {
                                ActionSheet(title: Text("Do you want to accept the request?"), message: nil, buttons: [.default(Text("Accept"), action: {
                                    if let notification = self.selectNotification {
                                        if let invitation = notification.action as? Invitation {
                                            YKNetworkManager.Invitations.handle(invitation: invitation, status: .accept)
                                            self.notifications.removeAll(where: { $0.id == notification.id })
                                        }
                                    }
                                }), .destructive(Text("Deny"), action: {
                                    if let notification = self.selectNotification {
                                        if let invitation = notification.action as? Invitation {
                                            YKNetworkManager.Invitations.handle(invitation: invitation, status: .deny)
                                            self.notifications.removeAll(where: { $0.id == notification.id })
                                        }
                                    }
                                }), .cancel()])
                            }
                    }
                }
            }.navigationBarTitle("Notifications", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primary)
                        .imageScale(.medium)
                        .padding(8)
                        .background(Circle().fill(Color(UIColor.systemGray6)))
                        .padding()
                }))
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    func handleNotification(_ notification: YKNotification) {
        selectNotification = notification
        if notification.action is Invitation {
            presentAcceptDeny = true
        } else {
            print("Don't know that action")
        }
    }
}
