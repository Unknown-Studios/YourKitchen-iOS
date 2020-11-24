//
//  WebViewModel.swift
//  YourKitchen
//
//  Created by Markus Moltke on 05/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

class WebViewModel: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false

    init(link: String) {
        self.link = link
    }
}
