//
//  TrackableScrollView.swift
//  TrackableScrollView
//
//  Created by maxnatchanon on 26/12/2019 BE.
//  Copyright © 2019 maxnatchanon All rights reserved.
//

import SwiftUI

struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @ObservedObject var scrollHelper = ScrollHelper()
    @State var contentOffset : CGFloat = 0.0
    let content: Content
    var endReached: (() -> Void)?
    var onRefresh: (() -> Void)?
    
    @State var currentHeight: CGFloat = 0.0

    init(_ axes: Axis.Set = .vertical, showIndicators: Bool = true, endReached: (() -> Void)? = nil, onRefresh: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self.onRefresh = onRefresh
        self.content = content()
        self.endReached = endReached
    }

    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    VStack {
                        self.content
                    }.padding(.top, 20)
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
                        if onRefresh != nil {
                            VStack {
                                HStack {
                                    Spacer()
                                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                                        .opacity((outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY < 0) ? Double(abs(outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY)).clamped(0.0, 50.0) / 50.0 : 0.0)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.contentOffset = value[0]
                }
            }
        }
    }

    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        let scrollHeight = (insideProxy.size.height - outsideProxy.size.height)
        let currentHeight = outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY

        if (currentHeight <= -50 && !self.scrollHelper.refresh) {
            self.scrollHelper.setRefresh(true)
        } else if (currentHeight >= -5 && self.scrollHelper.refresh) { //Refresh release (-5 because the animation is pretty slow otherwise)
            self.scrollHelper.setRefresh(false)
            print("Refreshing")
            DispatchQueue.main.async {
                onRefresh?()
            }
        }
        
        if currentHeight / scrollHeight >= 0.8, let endReached = endReached { //If we are 80% towards the end
            endReached()
        }

        if axes == .vertical {
            return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
        } else {
            return outsideProxy.frame(in: .global).minX - insideProxy.frame(in: .global).minX
        }
    }
}

class ScrollHelper : ObservableObject {
    @Published var refresh = false
    @Published var opacity: Double = 0.0
    
    func setRefresh(_ state: Bool) {
        self.refresh = state
    }
}

extension Comparable {
    func clamped(_ f: Self, _ t: Self)  ->  Self {
        var r = self
        if r < f { r = f }
        if r > t { r = t }
        // (use SIMPLE, EXPLICIT code here to make it utterly clear
        // whether we are inclusive, what form of equality, etc etc)
        return r
    }
}
