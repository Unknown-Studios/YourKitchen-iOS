//
//  IAPManager.swift
//  Apphud
//
//  Created by Apphud on 04/01/2019.
//  Copyright © 2019 Apphud. All rights reserved.
//

import FirebaseFirestore
import StoreKit
import SwiftyStoreKit
import UIKit

public typealias SuccessBlock = () -> Void
public typealias FailureBlock = (Error?) -> Void
public typealias ProductsBlock = ([SKProduct]) -> Void

let IAP_PRODUCTS_DID_LOAD_NOTIFICATION = Notification.Name("IAP_PRODUCTS_DID_LOAD_NOTIFICATION")

class IAPManager: NSObject {
    private var sharedSecret = ""
    @objc static let shared = IAPManager()
    @objc private(set) var products = [SKProduct]()
    private(set) var purchased = [String]()

    override private init() {}
    private var productIds: Set<String> = []

    private var didLoadsProducts: ProductsBlock?

    private var successBlock: SuccessBlock?
    private var failureBlock: FailureBlock?

    // MARK: - Main methods

    @objc func startWith(arrayOfIds: Set<String>!, sharedSecret: String, callback: @escaping ProductsBlock) {
        didLoadsProducts = callback
        self.sharedSecret = sharedSecret
        productIds = arrayOfIds
        loadProducts()
    }

    func purchaseProduct(product: SKProduct, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
        if SwiftyStoreKit.canMakePayments {
            SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                switch result {
                case let .success(product):
                    // fetch content from your server, then:
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                    print("Purchase Success: \(product.productId)")
                    self.refreshReceipt()
                    success()
                case let .error(error):
                    failure(error)
                    switch error.code {
                    case .unknown: print("Unknown error. Please contact support")
                    case .clientInvalid: print("Not allowed to make the payment")
                    case .paymentCancelled: break
                    case .paymentInvalid: print("The purchase identifier was invalid")
                    case .paymentNotAllowed: print("The device is not allowed to make the payment")
                    case .storeProductNotAvailable: print("The product is not available in the current storefront")
                    case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                    case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                    default: print((error as NSError).localizedDescription)
                    }
                }
            }
        }
    }

    func restorePurchases(_ success : @escaping SuccessBlock, _ failure : @escaping FailureBlock) {
        self.failureBlock = failure
        self.successBlock = success
        SwiftyStoreKit.restorePurchases(atomically: true) { result in
            guard result.restoreFailedPurchases.count == 0 else {
                if let failureBlock = self.failureBlock {
                    failureBlock(nil)
                    self.failureBlock = nil
                    self.successBlock = nil
                }
                print("An error occured")
                return
            }
            self.refreshReceipt()
            if let successBlock = self.successBlock {
                successBlock()
                self.failureBlock = nil
                self.successBlock = nil
            }
        }
    }

    /*
     Private method. Should not be called directly. Call refreshSubscriptionsStatus instead.
     */
    private func refreshReceipt() {
        #if DEBUG
            let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: "1b60ed7d1b7b4ef98648f044ebb17cb3")
        #else
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "1b60ed7d1b7b4ef98648f044ebb17cb3")
        #endif
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case let .success(receipt):
                let productId = "com.unknownstudios.yourkitchen.premium"
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt
                )

                let completion = { (user : YKUser) in
                    YKNetworkManager.Users.get { (_) in }
                }

                switch purchaseResult {
                case let .purchased(expiryDate, items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                    self.purchased.append(productId)
                    YKNetworkManager.Users.update(array: ["premium": expiryDate], completion)
                case let .expired(expiryDate, items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    YKNetworkManager.Users.update(array: ["premium": FieldValue.delete()], completion)
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }
            case let .error(error):
                print("Receipt verification failed: \(error)")
            }
        }
    }

    private func loadProducts() {
        SwiftyStoreKit.retrieveProductsInfo(productIds) { result in
            self.products.removeAll()
            if let product = result.retrievedProducts.first {
                self.products.append(product)
            } else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            } else if let error = result.error {
                print("Error: \(error.localizedDescription)")
            }
            if let didLoadsProducts = self.didLoadsProducts {
                didLoadsProducts(self.products)
            }
            self.refreshReceipt()
        }
    }
}

// MARK: - SKProducts Request Delegate

extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: IAP_PRODUCTS_DID_LOAD_NOTIFICATION, object: nil)
            if response.products.count > 0 {
                self.didLoadsProducts?(self.products)
                self.didLoadsProducts = nil
            }
        }
    }
}
