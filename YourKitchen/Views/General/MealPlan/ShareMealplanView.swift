//
//  ShareMealplanView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import ActionOver
import SwiftUI

public struct ShareMealplanView: View {
    @State var sharedInvitations = [Invitation]()
    @State var sharedUsers = [YKUser]()
    @State var joinedMealplans = [SocialMealplan]()

    @State var presentAction = false
    @State var presentAdd = false
    @State var isEditing = false

    public var body: some View {
        Form {
            if self.joinedMealplans.count > 0 {
                Section(header: Text("Followed Meal Plans")) {
                    List {
                        ForEach(self.joinedMealplans) { mealplan in
                            VStack {
                                HStack {
                                    Text(mealplan.owner.firstName + "s Meal Plan")
                                    Spacer()
                                }
                                HStack {
                                    Text(mealplan.owner.email)
                                        .foregroundColor(Color.secondary)
                                        .font(.system(size: 15))
                                    Spacer()
                                }
                                Spacer()
                            }
                        }.onDelete(perform: self.deleteIdFromMe)
                    }
                }
            }
            if self.sharedUsers.count > 0 {
                Section(header: Text("Users Following My Meal Plan")) {
                    List {
                        ForEach(self.sharedUsers) { user in
                            VStack {
                                HStack {
                                    Text(user.name)
                                    Spacer()
                                }
                                HStack {
                                    Text(user.email)
                                        .foregroundColor(Color.secondary)
                                        .font(.system(size: 15))
                                    Spacer()
                                }
                                Spacer()
                            }
                        }.onDelete(perform: self.deleteMyID)
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
        }.environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring()).navigationBarTitle("Share Mealplan")
            .navigationBarItems(trailing: Button(action: {
                self.presentAction = true
            }, label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .padding()
            }).actionOver(presented: self.$presentAction,
                          title: "Action:",
                          message: nil,
                          buttons: [.init(title: "Edit", type: .normal, action: {
                              self.isEditing = !self.isEditing
                          }),
                          .init(title: "Invite User", type: .normal, action: {
                              self.presentAdd = true
                          }),
                          .init(title: nil, type: .cancel, action: nil)],
                          ipadAndMacConfiguration: ipadMacConfig)
            ).sheet(isPresented: self.$presentAdd, content: {
                SelectUserView(completion: { user in
                    // Check that we don't already have the user in our sharedUsers
                    if self.sharedUsers.contains(user) {
                        print("User already exists")
                        return
                    }

                    // Invitation doesn't exist handled in add function
                    YKNetworkManager.Invitations.add(to: user, type: "mealplan") { invitation in
                        self.sharedInvitations.append(invitation)
                    }
                })
            })
            .onAppear {
                self.refreshShared()
            }
    }

    public var ipadMacConfig = {
        IpadAndMacConfiguration(anchor: nil, arrowEdge: nil)
    }()

    func deleteIdFromMe(at indexSet: IndexSet) {
        for index in indexSet {
            let item = joinedMealplans[index]
            YKNetworkManager.Mealplans.get { mealplans in
                if mealplans.count > 0 {
                    let ownMealplan = mealplans[0]
                    ownMealplan.shareIDs.removeAll(where: { $0 == item.owner.id })
                    YKNetworkManager.shared.updateAll("mealplans", values: ["shareIDs": ownMealplan
                            .shareIDs]) {
                        self.joinedMealplans.remove(atOffsets: indexSet)
                    }
                }
            }
        }
    }

    func deleteMyID(at indexSet: IndexSet) {
        for index in indexSet {
            let item = sharedUsers[index]
            YKNetworkManager.Mealplans.deleteMyId(owner: item) {
                self.sharedUsers.remove(atOffsets: indexSet)
            }
        }
    }

    func deleteInvitation(at indexSet: IndexSet) {
        for index in indexSet {
            let item = sharedInvitations[index]
            YKNetworkManager.Invitations.delete(id: item.id)
        }
        sharedInvitations.remove(atOffsets: indexSet)
    }

    func refreshShared() {
        YKNetworkManager.Mealplans.getShared { mealplans in
            self.joinedMealplans = mealplans
        }
        YKNetworkManager.Mealplans.getSharedUsers { users in
            self.sharedUsers = users
        }
        YKNetworkManager.Invitations.getInvitations(type: "mealplan") { invitations in
            self.sharedInvitations = invitations
        }
    }
}
