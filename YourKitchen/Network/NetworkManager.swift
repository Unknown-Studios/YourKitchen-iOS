//
//  NetworkManager.swift
//  iOS-Template
//
//  Created by Markus Moltke on 21/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Alamofire
import UIKit

public typealias NM = NetworkManager
public class NetworkManager {
    // Login request
    public struct Login: Encodable {
        var email: String
        var password: String
    }

    static let shared = NetworkManager()

    public func loginRequest(url: String, login: Login, handler: @escaping ((AFDataResponse<Data?>) -> Void)) {
        AF.request(url,
                   method: .post,
                   parameters: login,
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200 ... 300)
            .response(completionHandler: handler)
    }

    public func loginRequestJSON(url: String, login: Login, handler: @escaping ((AFDataResponse<Any>) -> Void)) {
        AF.request(url,
                   method: .post,
                   parameters: login,
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200 ... 300)
            .responseJSON(completionHandler: handler)
    }

    // Normal Requests
    public func request(url: String, handler: @escaping ((AFDataResponse<Data?>) -> Void)) {
        AF.request(url)
            .validate(statusCode: 200 ... 300)
            .response(completionHandler: handler)
    }

    public func request(url: String, method _: HTTPMethod, handler: @escaping ((AFDataResponse<Data?>) -> Void)) {
        AF.request(url)
            .validate(statusCode: 200 ... 300)
            .response(completionHandler: handler)
    }

    // JSON Requests
    public func requestJSON(url: String, handler: @escaping ((AFDataResponse<Any>) -> Void)) {
        AF.request(url)
            .validate(statusCode: 200 ... 300)
            .responseJSON(completionHandler: handler)
    }

    public func requestJSON(url: String, method _: HTTPMethod, handler: @escaping ((AFDataResponse<Any>) -> Void)) {
        AF.request(url)
            .validate(statusCode: 200 ... 300)
            .responseJSON(completionHandler: handler)
    }

    public func requestImage(url: String, handler: @escaping (UIImage?) -> Void) {
        AF.request(url)
            .validate(statusCode: 200 ... 300)
            .validate(contentType: ["image/*"])
            .responseData { response in
                switch response.result {
                case let .success(data):
                    if let image = UIImage(data: data) {
                        handler(image)
                    }
                case let .failure(err):
                    print(err.localizedDescription)
                    handler(nil)
                }
            }
    }
}
