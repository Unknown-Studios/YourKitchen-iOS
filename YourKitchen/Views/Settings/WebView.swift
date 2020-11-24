//
//  WebViewView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 05/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct WebView: View {
    @ObservedObject var model: WebViewModel

    init(url: String) {
        model = WebViewModel(link: url)
    }

    var body: some View {
        YKWebView(viewModel: model)
    }
}
