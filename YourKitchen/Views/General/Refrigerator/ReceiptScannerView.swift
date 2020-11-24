//
//  ReceiptScannerView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 14/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
/*
struct ReceiptScannerView: View {
    
    @State private var isShowingScannerSheet = false
    @State private var text: String = ""
    
    var viewModel = ScannerViewModel()
     
    var body: some View {
        VStack {
            Text("Vision Kit Example")
            Button(action: openCamera) {
                Text("Scan").foregroundColor(.white)
            }
                .background(Color.blue)
                .cornerRadius(3.0)
            ScrollView {
                Text(text).lineLimit(nil)
            }
        }.sheet(isPresented: self.$isShowingScannerSheet) {
            self.makeScannerView()
        }
    }
     
     
    private func openCamera() {
        isShowingScannerSheet = true
    }
     
    private func makeScannerView() -> ScannerView {
        ScannerView(completion: { textPerPage in
            if let textPerPage = textPerPage {
                self.viewModel.fixScan(textPerPage)
            }
            self.isShowingScannerSheet = false
        })
    }
}
*/
