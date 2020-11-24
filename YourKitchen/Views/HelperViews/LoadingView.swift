//
//  LoadingView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 22/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct LoadingView<Content : View>: View {
    
    var title : String?
    @Binding var loading : Bool
    var content : () -> Content
    
    var body: some View {
        VStack {
            if (self.loading) {
                Text(self.title ?? "")
                    .foregroundColor(Color.secondary)
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            } else {
                self.content()
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(loading: .constant(true)) {
            Text("Hey")
        }
    }
}
