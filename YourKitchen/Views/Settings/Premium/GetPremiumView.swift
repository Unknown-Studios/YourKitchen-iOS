//
//  GetPremiumView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 17/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Combine
import StoreKit
import SwiftUI
import FirebaseAnalytics

struct GetPremiumView: View {
    @State private var isDisabled: Bool = false
    @ObservedObject var productsStore = ProductsStore()

    @Environment(\.presentationMode) var presentationMode

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Get Premium Membership").font(.title)
                Spacer()
                    .frame(height: 20)
                self.aboutText()
                Spacer()
                    .frame(height: 20)

                self.purchaseButtons()

                Spacer()
                self.helperButtons()
            }
            .disabled(self.isDisabled)
            .navigationBarItems(trailing: Button(action: {
                self.dismiss()
            }, label: {
                Image(systemName: "multiply")
                    .foregroundColor(AppConstants.Colors.YKColor)
                    .font(.system(size: 22))
            }).padding())
        }.onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "Premium",
                                            AnalyticsParameterScreenClass: GetPremiumView.self])
        }
    }

    // MARK: - View creations

    func purchaseButtons() -> some View {
        // remake to ScrollView if has more than 2 products because they won't fit on screen.
        HStack {
            Spacer()
            ForEach(self.productsStore.products, id: \.self) { prod in
                Button(action: {
                    self.purchaseProduct(skproduct: prod)
                }, label: {
                    Text("Premium - " + prod.localizedPrice())
                        .foregroundColor(Color.white)
                        .frame(width: 280, height: 45)
                        .background(RoundedRectangle(cornerRadius: 10.0).fill(self.isDisabled ? .gray : (IAPManager.shared.purchased.contains(prod.productIdentifier) ? .gray : AppConstants.Colors.YKColor))) //If either purchased (Shouldn't be visible) or if disabled by operation
                }).disabled(IAPManager.shared.purchased.contains(prod.productIdentifier))
            }
            Spacer()
        }
    }

    /**
     Returns helper button (Restore purchases)
     */
    func helperButtons() -> some View {
        HStack {
            Button(action: self.restorePurchases, label: {
                Text("Restore Purchases")
                    .foregroundColor(Color.white)
                    .frame(width: 280, height: 45)
                    .background(RoundedRectangle(cornerRadius: 10.0).fill(self.isDisabled ? .gray : AppConstants.Colors.YKColor)) //If either purchased (Shouldn't be visible) or if disabled by operation
            })
        }
    }

    /**
     Returns about text as a Text element
     */
    func aboutText() -> some View {
        Text("""
        • Better meal plan generation
        • No ads
        • Better suggestions throughout the app
        """).font(.subheadline).lineLimit(nil)
    }

    // MARK: - Actions

    func restorePurchases() {
        self.isDisabled = true
        IAPManager.shared.restorePurchases({
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
            self.dismiss()
        }) { _ in
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
        }
    }

    func purchaseProduct(skproduct: SKProduct) {
        print("did tap purchase product: \(skproduct.productIdentifier)")
        isDisabled = true
        IAPManager.shared.purchaseProduct(product: skproduct, success: {
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
            self.dismiss()
        }) { _ in
            self.isDisabled = false
            ProductsStore.shared.handleUpdateStore()
        }
    }
}
