//
//  Search+YKNetwork.swift
//  YourKitchen
//
//  Created by Markus Moltke on 13/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import Foundation

public extension YKNetworkManager {
    enum Search {
        public static func search(search_query: String, types: [String] = [String](), completion: @escaping ([SearchResult]) -> Void) {
            // Cancel earlier requests
            Alamofire.Session.default.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                dataTasks.forEach {
                    if let searchRequest = $0.originalRequest?.url?.absoluteString.starts(with: "https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/search"), searchRequest {
                        $0.cancel()
                    }
                }
                uploadTasks.forEach {
                    if let searchRequest = $0.originalRequest?.url?.absoluteString.starts(with: "https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/search"), searchRequest {
                        $0.cancel()
                    }
                }
                downloadTasks.forEach {
                    if let searchRequest = $0.originalRequest?.url?.absoluteString.starts(with: "https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/search"), searchRequest {
                        $0.cancel()
                    }
                }
            }

            // Make new request
            let typeString = types.joined(separator: ",")

            AF.request("https://europe-west3-yourkitchen-1e9e1.cloudfunctions.net/search?search_query=" + search_query + (types.count != 0 ? ("&types=" + typeString) : ""))
                .validate(statusCode: 200 ..< 300)
                .responseDecodable(of: [SearchResult].self) { (result) in
                    switch result.result {
                    case .success(let result):
                        completion(result)
                        break
                    case .failure(let err):
                        if let data = result.data {
                            print(String(data: data, encoding: .utf8) ?? "")
                        }
                        if (!err.localizedDescription.contains("cancelled")) { //Prevents calls when typing faster than response
                            UserResponse.displayError(msg: err.localizedDescription)
                        }
                    }
                }
        }
    }
}
