//
//  MultilineTextField.swift
//  YourKitchen
//
//  Created by Markus Moltke on 05/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import UIKit

struct MultilineTextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @State var placeholder: String
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self, placeholder: placeholder)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.text = placeholder
        view.textColor = UIColor.tertiaryLabel
        view.font = UIFont(name: view.font!.fontName, size: 18)
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if !text.isEmpty {
            textView.text = text
            textView.textColor = UIColor.label
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var textArea: MultilineTextView
        var placeholder: String

        init(_ textArea: MultilineTextView, placeholder: String) {
            self.textArea = textArea
            self.placeholder = placeholder
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.tertiaryLabel {
                textView.text = nil
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textColor = UIColor.tertiaryLabel
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.textArea.text = textView.text
        }
    }
}
