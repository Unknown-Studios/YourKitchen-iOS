//
//  ShoppingListView.swift
//  WatchOS Extension
//
//  Created by Markus Moltke on 01/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import Foundation
import SwiftUI
import UIKit

struct ShoppingListView: View {
    @State var shoppingList = [Ingredient]()
    @State var selectShopping = [Ingredient: Bool]()

    var body: some View {
        List {
            ForEach(self.shoppingList, id: \.self) { item in
                Button(action: {
                    self.selectShopping[item] = !(self.selectShopping[item] ?? false)
                    self.updateShoppingList()
                }) {
                    HStack {
                        Image(systemName: self.selectShopping[item] ?? false ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(self.selectShopping[item] ?? false ? .green : .primary)
                            .imageScale(.large)
                        VStack(alignment: .leading) {
                            Text(item.amountDescription)
                            Text(item.name)
                        }
                        Spacer()
                    }
                }.padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
            }
        }.padding(.horizontal, 8)
            .onAppear {
                self.getShoppingList()
            }
    }

    func getShoppingList() {
        print("Getting shopping list")
        guard let userID = UserDefaults.standard.string(forKey: "main-account") else { return }
        AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/getShoppingList?userID=" + userID)
            .validate(statusCode: 200 ..< 300)
            .responseDecodable(of: [Ingredient].self) { response in
                switch response.result {
                case let .success(ingredients):
                    print("Success")
                    self.shoppingList = ingredients
                case let .failure(err):
                    print(response.description)
                    print(err.localizedDescription)
                }
            }
    }

    func updateShoppingList() {
        guard let userID = UserDefaults.standard.string(forKey: "main-account") else { return }
        let tmpShoppingList = shoppingList.filter {
            !(self.selectShopping[$0] ?? false)
        }
        if let json = try? JSONEncoder().encode(tmpShoppingList), let jsonString = String(data: json, encoding: .utf8) {
            let data = [
                "shoppingList": jsonString
            ]
            AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/updateShoppingList?userID=" + userID, method: .post, parameters: data, encoder: JSONParameterEncoder())
                .validate(statusCode: 200 ..< 300)
                .responseString { response in
                    switch response.result {
                    case let .success(result):
                        print(result)
                    case let .failure(err):
                        print(err.localizedDescription)
                    }
                }
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
