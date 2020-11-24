//
//  SpotlightHelper.swift
//  YourKitchen
//
//  Created by Markus Moltke on 10/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import CoreSpotlight
import Kingfisher
import MobileCoreServices

public enum SpotlightHelper {
    public static func setupSearchableContent() {
        var searchableItems = [CSSearchableItem]()
        let completeHandling = {
            CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: { (err) -> Void in
                if let err = err {
                    UserResponse.displayError(msg: err.localizedDescription)
                    return
                }
                CSSearchableIndex.default().indexSearchableItems(searchableItems) { err in
                    if let err = err {
                        UserResponse.displayError(msg: err.localizedDescription)
                        return
                    }
                    print("Indexed recipes")
                }
            })
        }
        YKNetworkManager.Recipes.getAll(cache: false) { recipes in
            var c = 0
            for recipe in recipes {
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)

                // Set already known data
                searchableItemAttributeSet.title = recipe.name
                searchableItemAttributeSet.rating = NSNumber(value: recipe.rating)
                searchableItemAttributeSet.contentDescription = recipe.description
                searchableItemAttributeSet.artist = recipe.author.name
                searchableItemAttributeSet.addedDate = recipe.dateAdded

                guard let url = recipe.image.url else { c += 1; continue } // No image, but we still need to continue
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    c += 1
                    switch result {
                    case let .success(value):
                        let tmpImage = value.image.imageWithSize(size: CGSize(width: 300, height: 300))
                        let data = tmpImage.jpegData(compressionQuality: 0.7)
                        searchableItemAttributeSet.thumbnailData = data

                        let identifier = Bundle.main.bundleIdentifier!
                        let searchableItem = CSSearchableItem(uniqueIdentifier: identifier + "." + recipe.id, domainIdentifier: "recipes", attributeSet: searchableItemAttributeSet)

                        searchableItems.append(searchableItem)
                    case let .failure(error):
                        print(error)
                    }
                    if c >= recipes.count {
                        completeHandling()
                    }
                }
            }
        }
    }
}
