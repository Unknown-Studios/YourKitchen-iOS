//
//  Time.swift
//  YourKitchen
//
//  Created by Markus Moltke on 06/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public struct Time {
    public var hour: Int
    public var minute: Int
    
    func isUnder(_ time : Time) -> Bool {
        //Hour is under
        if (time.hour > self.hour) {
            return true
        }
        //Hour is same, but minute is under
        if (time.hour == self.hour && time.minute >= time.minute) {
            return true
        }
        return false
    }

    var description: String {
        return hour.description + "h " + minute.description + "m"
    }
}

extension Time: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hour = try values.decode(Int.self, forKey: .hour)
        minute = try values.decode(Int.self, forKey: .minute)
    }

    enum CodingKeys: String, CodingKey {
        case hour
        case minute
    }
}
