//
//  ShareRefrigeratorView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 11/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ActionOver
import SwiftUI

struct ShareRefrigeratorView: View {
    @Binding var isHost: Bool
    @State var sharedInvitations = [Invitation]()
    @State var sharedUsers = [YKUser]()

    @State var presentAction = false
    @State var presentAdd = false
    @State var isEditing = false

    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        Form {
            if self.sharedUsers.count > 0 {
                Section(header: Text("Shared with")) {
                    List {
                        ForEach(self.sharedUsers) { user in
                            VStack {
                                Text(user.name)
                            }
                        }.onDelete(perform: self.deleteUser)
                    }
                }
            }
            if self.sharedInvitations.count > 0 {
                Section(header: Text("Invitations")) {
                    List {
                        ForEach(self.sharedInvitations) { invitation in
                            VStack {
                                HStack {
                                    Text(invitation.other.name)
                                    Spacer()
                                }
                                HStack {
                                    Text("Pending")
                                        .foregroundColor(Color.secondary)
                                        .font(.system(size: 15))
                                    Spacer()
                                }
                            }
                        }.onDelete(perform: self.deleteInvitation)
                    }
                }
            }
        }.environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring())
            .navigationBarTitle("Share Refrigerator")
            .navigationBarItems(trailing: Button(action: {
                self.presentAction = true
            }, label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .padding()
            }).actionOver(presented: self.$presentAction,
                          title: "Action:",
                          message: nil,
                          buttons: self.getActionButtons(),
                          ipadAndMacConfiguration: ipadMacConfig)
            ).sheet(isPresented: self.$presentAdd, content: {
                SelectUserView(completion: { user in
                    YKNetworkManager.Invitations.add(to: user, type: "refrigerator") { invitation in
                        self.sharedInvitations.append(invitation)
                    }
                })
            })
            .onAppear {
                self.refreshShared()
            }
    }

    public func getActionButtons() -> [ActionOverButton] {
        if isHost {
            return [ActionOverButton(title: "Edit", type: .normal, action: {
                self.isEditing = !self.isEditing
            }), ActionOverButton(title: "Invite user", type: .normal, action: {
                self.presentAdd = true
            }), ActionOverButton(title: nil, type: .cancel, action: nil)]
        } else {
            return [ActionOverButton(title: "Leave Refrigerator", type: .destructive, action: {
                YKNetworkManager.Refrigerators.update(shareID: nil) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }), ActionOverButton(title: nil, type: .cancel, action: nil)]
        }
    }

    public var ipadMacConfig = {
        IpadAndMacConfiguration(anchor: nil, arrowEdge: nil)
    }()

    func deleteUser(at indexSet: IndexSet) {
        for index in indexSet {
            let item = sharedUsers[index]
            YKNetworkManager.Refrigerators.isHost { value in
                if value { // If we are the host of people
                    // Delete from them
                    YKNetworkManager.Refrigerators.update(user: item, shareID: nil)
                } else { // If we have joined another refrigerator
                    // Delete the shareID from myself
                    YKNetworkManager.Refrigerators.update(shareID: nil)
                }
            }
        }
        sharedUsers.remove(atOffsets: indexSet)
    }

    func deleteInvitation(at indexSet: IndexSet) {
        for index in indexSet {
            let item = sharedInvitations[index]
            YKNetworkManager.Invitations.delete(id: item.id)
        }
        sharedInvitations.remove(atOffsets: indexSet)
    }

    func refreshShared() {
        YKNetworkManager.Refrigerators.getSharedUsers { users in
            self.sharedUsers = users
        }
        YKNetworkManager.Invitations.getInvitations(type: "refrigerator") { invitations in
            self.sharedInvitations = invitations
        }
    }
}
