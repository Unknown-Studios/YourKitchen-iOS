//
//  LikesOnboardingView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 22/10/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct LikesOnboardingView: View {
    @Binding var likes: [Cuisine]
    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            Text("Likes")
                .foregroundColor(Color.white)
                .font(.title)
                .bold()
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(width: 300, height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Cuisine.allCases, id: \.self) { platform in
                Button {
                    if self.likes.contains(platform) {
                        self.likes.removeAll(where: { $0 == platform })
                    } else {
                        self.likes.append(platform)
                    }
                } label: {
                    self.item(for: platform)
                        .padding([.horizontal, .vertical], 4)
                        .alignmentGuide(.leading, computeValue: { d in
                            if abs(width - d.width) > g.size.width {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if platform == Cuisine.allCases.last! {
                                width = 0 // last item
                            } else {
                                width -= d.width
                            }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: { _ in
                            let result = height
                            if platform == Cuisine.allCases.last! {
                                height = 0 // last item
                            }
                            return result
                        })
                }
            }
        }.background(viewHeightReader($totalHeight))
    }

    func item(for cuisine: Cuisine) -> some View {
        Text(cuisine.prettyName)
            .font(.body)
            .foregroundColor(Color.white)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10.0).fill(self.likes.contains(cuisine) ? Color.green : Color(UIColor.systemGray4)))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct LikesOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        LikesOnboardingView(likes: .constant([]))
    }
}
