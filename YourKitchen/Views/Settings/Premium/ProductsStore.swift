//
//  ProductsStore.swift
//  https://apphud.com
//
//  Created by Apphud on 22/06/2019.
//  Copyright © 2019 apphud. All rights reserved.
//

import Combine
import Foundation
import StoreKit
import SwiftUI

class ProductsStore: ObservableObject {
    static let shared = ProductsStore()

    @Published var products: [SKProduct] = []
    @Published var anyString = "123" // little trick to force reload ContentView from PurchaseView by just changing any Published value

    func handleUpdateStore() {
        anyString = UUID().uuidString
    }

    init() {
        IAPManager.shared.startWith(arrayOfIds: ["com.unknownstudios.yourkitchen.premium"], sharedSecret: "1b60ed7d1b7b4ef98648f044ebb17cb3") { products in
            self.products = products
        }
    }
}
