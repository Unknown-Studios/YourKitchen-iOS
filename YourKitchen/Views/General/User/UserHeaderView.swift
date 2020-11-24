//
//  UserHeaderView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 11/11/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage
import ActionOver

struct UserHeaderView: View {
    
    @Binding var user : YKUser
    
    @State var following = false
    @State var followersArr = [YKUser]()
    @State var followingArr = [YKUser]()
    
    @State var image : UIImage?
    @State var showImageAction = false
    @State var showImagePicker = false
    @State var showTakePhoto = false
    
    init(user : Binding<YKUser>) {
        self._user = user
    }
    
    var body: some View {
        VStack {
            Button(action: {
                if self.isOwnProfile() {
                    self.showImageAction = true
                }
            }) {
                KFImage(self.user.image.url)
                    .placeholder {
                        Image("UserImage")
                            .resizable()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150.0, height: 150.0)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            }.buttonStyle(PlainButtonStyle())
                .actionOver(
                    presented: self.$showImageAction,
                    title: "Image Picker",
                    message: nil,
                    buttons: [
                        ActionOverButton(
                            title: "Take Photo",
                            type: .normal,
                            action: {
                                self.showTakePhoto = true
                            }
                        ),
                        ActionOverButton(
                            title: "Select Photo",
                            type: .normal,
                            action: {
                                self.showImagePicker = true
                            }
                        ),
                        ActionOverButton(
                            title: nil,
                            type: .cancel,
                            action: nil
                        )
                    ],
                    ipadAndMacConfiguration: self.ipadMacConfig
                )
            if !self.isOwnProfile() { // If we do not own this profile the user should be allowed to follow it.
                Button {
                    self.following = !self.following
                    self.followingStateChanged()
                } label: {
                    Text(self.following ? "Unfollow" : "Follow")
                        .foregroundColor(self.following ? Color.primary : Color.white)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10.0).fill(self.following ? Color.gray.opacity(0.35) : AppConstants.Colors.YKColor))
                }.padding()

            }
            HStack {
                followingButton(followType: .followers)
                Divider().background(Color.gray)
                followingButton(followType: .following)
                Divider().background(Color.gray)
                VStack {
                    Text(self.user.score.description)
                    Text("Score")
                        .foregroundColor(Color.secondary)
                        .font(.system(size: 15.0))
                }
            }.padding()
        }.onAppear {
            self.refreshFollowing()
            self.refreshFollowing()
            self.getFollowerArrays()
        }
        .sheet(isPresented: showSheet) {
            if self.showImagePicker {
                YKImagePicker(image: self.$image) {
                    self.uploadImage()
                }
            } else if self.showTakePhoto {
                YKTakePhoto(image: self.$image) {
                    self.uploadImage()
                }
            } else {
                EmptyView()
            }
        }
        .padding()
    }
    
    func getFollowerArrays() {
        YKNetworkManager.Users.getFollowersForUser(self.user) { followers in
            self.followersArr = followers
        }
        YKNetworkManager.Users.getFollowingForUser(self.user) { following in
            self.followingArr = following
        }
    }
    
    var showSheet: Binding<Bool> {
        if self.showImagePicker {
            return self.$showImagePicker
        } else if self.showTakePhoto {
            return self.$showTakePhoto
        } else {
            return .constant(false)
        }
    }
    
    func refreshFollowing() {
        YKNetworkManager.Users.get { user in
            guard let user = user else { return }
            self.following = user.following.contains(self.user.id)
        }
    }
    
    func followingButton(followType: FollowingType) -> some View {
        NavigationLink(destination: UserFollowersView(followers: self.$followersArr,
                                                      following: self.$followingArr,
                                                      followingState: followType)) {
            VStack {
                Text((followType == .followers ? self.followersArr : self.followingArr).count.description)
                Text(NSLocalizedString(followType == .followers ? "Followers" : "Following", comment: ""))
                    .foregroundColor(Color.secondary)
                    .font(.system(size: 15.0))
            }
        }.buttonStyle(HighPriorityButtonStyle())
    }
    
    func followingStateChanged() {
        YKNetworkManager.Users.updateFollowing(followUser: self.user,
                                               follow: self.following) { user in
            print("Following updated: " + user.following.contains(self.user.id).description)
            self.following = user.following.contains(self.user.id)
        }
    }
    
    private var ipadMacConfig = {
        IpadAndMacConfiguration(anchor: nil, arrowEdge: nil)
    }()
    
    func isOwnProfile() -> Bool {
        self.user == YKNetworkManager.shared.currentUser
    }
    
    func uploadImage() {
        guard let image = self.image else { return }
        YKNetworkManager.Users.updateImage(image: image) { url in
            self.user.image = url
        }
    }
}
