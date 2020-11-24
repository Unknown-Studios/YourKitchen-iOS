//
//  SelectUserView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct SelectUserView: View {
    var completion: (YKUser) -> Void
    @State var users = [YKUser]()
    @State var searchText = ""
    @State var searchResults = [SearchResult]()

    @Environment(\.presentationMode) var presentationMode

    init(completion: @escaping (YKUser) -> Void) {
        self.completion = completion
    }

    var body: some View {
        NavigationView {
            VStack {
                YKSearchBar(text: self.$searchText, placeholder: "Search")
                List {
                    ForEach(self.searchResults) { result in
                        if let user = result.object as? YKUser {
                            Button(action: {
                                self.completion(user)
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
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
                                }
                            }
                        } else {
                            EmptyView()
                        }
                    }
                }
            }.navigationBarTitle("Select User", displayMode: .inline)
                .onAppear {
                    self.refreshUsers()
                }
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

    func refreshUsers() {
        YKNetworkManager.Users.getAll { users in
            self.users = users
        }
    }

    func getSearch() {
        YKNetworkManager.Search.search(search_query: searchText, types: ["user"]) { results in
            self.searchResults = results
        }
    }
}

struct SelectUserView_Previews: PreviewProvider {
    static var previews: some View {
        SelectUserView { user in
            print(user.name)
        }
    }
}
