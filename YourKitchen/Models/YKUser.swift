//
//  YKUser.swift
//  YourKitchen
//
//  Created by Markus Moltke on 28/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

public struct YKUser: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var name: String
    public var email: String
    public var image: String
    public var score: Int = 0
    public var defaultPersons: Int = 0
    public var deviceToken = [String: String]()
    public var following: [String]
    public var allergenes = [Allergen]()
    public var adConsent = false
    public var privacyConsent = false
    public var reference: DocumentReference?
    private(set) var premium: Date? //Can only be interpreted from server

    var firstName: String {
        if let first = name.split(separator: " ").first {
            return String(first)
        }
        return name
    }

    public static func == (lhs: YKUser, rhs: YKUser) -> Bool {
        lhs.id == rhs.id
    }

    public static var none: YKUser {
        YKUser(id: "none", name: "", email: "", image: "", following: [])
    }

    init(id: String = UUID().uuidString, name: String, email: String, image: String, score: Int = 0, following: [String], allergenes: [Allergen] = [Allergen](), adConsent: Bool = false, privacyConsent: Bool = false, reference: DocumentReference? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.image = image
        self.score = score
        self.following = following
        self.allergenes = allergenes
        self.adConsent = adConsent
        self.privacyConsent = privacyConsent
        self.reference = reference
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = (try? values.decode(String.self, forKey: .name)) ?? "Anonymous"
        email = try values.decode(String.self, forKey: .email)
        image = try values.decode(String.self, forKey: .image)
        score = (try? values.decode(Int.self, forKey: .score)) ?? 0
        defaultPersons = (try? values.decode(Int.self, forKey: .defaultPersons)) ?? 1
        deviceToken = (try? values.decode([String: String].self, forKey: .deviceToken)) ?? [String: String]()
        following = (try? values.decode([String].self, forKey: .following)) ?? [String]()
        allergenes = (try? values.decode([Allergen].self, forKey: .allergenes)) ?? [Allergen]()
        adConsent = (try? values.decode(Bool.self, forKey: .adConsent)) ?? false
        privacyConsent = (try? values.decode(Bool.self, forKey: .privacyConsent)) ?? false
        reference = try? values.decode(DocumentReference.self, forKey: .reference)
        premium = try? values.decode(Date.self, forKey: .premium)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case image
        case score
        case defaultPersons
        case deviceToken
        case following
        case allergenes
        case adConsent
        case privacyConsent
        case reference
        case premium
    }
}

extension YKUser: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
