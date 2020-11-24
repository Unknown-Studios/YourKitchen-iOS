//
//  ImageHelper.swift
//  YourKitchen
//
//  Created by Markus Moltke on 08/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import Kingfisher
import SwiftUI

public enum ImageHelper {
    public static func getImage(url: String, _ completion: @escaping (SwiftUI.Image) -> Void) {
        guard let url = url.url else {
            return
        }
        KingfisherManager.shared.downloader.downloadImage(with: url, completionHandler: { result in
            switch result {
            case let .success(value):
                completion(SwiftUI.Image(uiImage: value.image))
            case let .failure(err):
                print(err.localizedDescription)
            }
        })
    }
}
