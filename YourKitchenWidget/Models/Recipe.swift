//
//  Recipe.swift
//  WatchOS Extension
//
//  Created by Markus Moltke on 07/11/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public class Recipe: Identifiable, Codable {
    public var id: String = UUID().uuidString
    public var name: String
    public var image: String

    public static var none: Recipe {
        Recipe(id: "none",
               name: "",
               image: "")
    }

    init(id: String = UUID().uuidString, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }

    var desc: String {
        name + " " + id
    }

    var idHex: Int {
        if let tmp = Int(Data(id.utf8).map { String(format: "%02x", $0) }.filter { Int($0) != nil }.joined()) {
            return tmp
        } else {
            return 0
        }
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        image = try values.decode(String.self, forKey: .image)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
    }
}

extension Recipe: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
