//
//  NotificationText.swift
//  NotificationText
//
//  Created by Markus Moltke on 09/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

public enum BadgeType {
    case small
    case large
}

struct BadgeText<Content: View>: View {
    @Binding var badgeCount: Int
    var badgeType: BadgeType
    var content: () -> Content

    init(badgeCount: Binding<Int> = .constant(0), badgeType: BadgeType = .large, _ content: @escaping () -> Content) {
        _badgeCount = badgeCount
        self.content = content
        self.badgeType = badgeType
    }

    var body: some View {
        ZStack {
            self.content()
            if self.badgeCount > 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text(self.badgeTitle)
                            .frame(height: badgeHeight)
                            .frame(minWidth: badgeHeight)
                            // .padding(.horizontal, badgeType == .small ? 0 : 2)
                            .background(RoundedRectangle(cornerRadius: badgeHeight / 2.0).fill(Color.red))
                            .foregroundColor(Color.white)
                            .offset(x: badgeHeight / 2.0, y: -(badgeHeight / 2.0))
                            .shadow(radius: 2.0)
                    }
                    Spacer()
                }
            }
        }.fixedSize()
    }

    var badgeTitle: String {
        if badgeType == .small {
            return ""
        } else {
            return badgeCount.description
        }
    }

    var badgeHeight: CGFloat {
        if badgeType == .small {
            return 10.0
        } else {
            return 25.0
        }
    }
}

struct BadgeText_Previews: PreviewProvider {
    static var previews: some View {
        BadgeText(badgeCount: .constant(3)) {
            Text("Test")
        }
    }
}
