//
//  UserFollowersView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import struct Kingfisher.KFImage
import SwiftUI

enum FollowingType: CaseIterable {
    case followers
    case following

    var caseName: String {
        "\(self)"
    }
}

struct UserFollowersView: View {
    @Binding var followers: [YKUser]
    @Binding var following: [YKUser]
    @State var user = YKUser(name: "", email: "", image: "", following: [])
    @State var followingArray = [String]()
    @State var followingState: FollowingType

    var body: some View {
        VStack {
            Picker(selection: self.$followingState, label: Text("")) {
                ForEach(FollowingType.allCases, id: \.self) { item in
                    Text(item.caseName.uppercased()).tag(item)
                }
            }.pickerStyle(SegmentedPickerStyle())
                .padding(8)
            List {
                ForEach((self.followingState == .followers) ? self.followers : self.following, id: \.self) { follower in
                    NavigationLink(destination: UserDetailView(user: follower)) {
                        HStack {
                            KFImage(follower.image.url)
                                .resizable()
                                .placeholder {
                                    Image("Placeholder")
                                }
                                .cancelOnDisappear(true)
                                .frame(width: 50.0, height: 50.0)
                                .clipShape(Circle())
                            HStack {
                                Text(follower.name)
                                Spacer()
                            }
                            Spacer()
                            Button(action: {
                                self.followingStateChanged(user: follower)
                            }) {
                                if self.getFollowStateOfUser(user: follower) {
                                    Text("Unfollow")
                                        .foregroundColor(Color.primary)
                                        .padding(8)
                                        .background(RoundedRectangle(cornerRadius: 10.0).fill(Color.gray.opacity(0.35)))
                                } else {
                                    Text("Follow")
                                        .foregroundColor(Color.white)
                                        .padding(8)
                                        .background(RoundedRectangle(cornerRadius: 10.0).fill(AppConstants.Colors.YKColor))
                                }
                            }
                            .buttonStyle(HighPriorityButtonStyle())
                        }
                    }
                }
            }.navigationBarTitle((followingState == .following) ? "Following" : "Followers")
        }.onAppear {
            self.refreshUser()
        }
    }

    func refreshUser() {
        YKNetworkManager.Users.get(cache: false) { user in
            guard let user = user else { return }
            self.user = user
            self.followingArray = user.following
        }
    }

    func getFollowStateOfUser(user: YKUser) -> Bool {
        self.followingArray.contains(where: { $0 == user.id })
    }

    func followingStateChanged(user: YKUser) {
        let newFollowingState = !self.getFollowStateOfUser(user: user)
        YKNetworkManager.Users.updateFollowing(followUser: user, follow: newFollowingState) { ownUser in
            self.followingArray = ownUser.following
            if self.followingState == .followers {
                YKNetworkManager.Users.getFollowersForUser(user) { newFollowers in
                    self.followers = newFollowers
                }
            } else {
                YKNetworkManager.Users.getFollowingForUser(user) { newFollowing in
                    self.following = newFollowing
                }
            }
        }
    }
}
