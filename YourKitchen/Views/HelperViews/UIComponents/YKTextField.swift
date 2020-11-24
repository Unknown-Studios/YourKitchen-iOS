//
//  YKTextField.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct YKTextField: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool = false
    var placeholder: String
    var onDone: (() -> Void)?
    var type: UIKeyboardType

    init(_ placeholder: String, text: Binding<String>, isFirstResponder: Bool = false, on done: (() -> Void)? = nil, type: UIKeyboardType = .default) {
        self.placeholder = placeholder
        _text = text
        self.isFirstResponder = isFirstResponder
        onDone = done
        self.type = type
    }

    func makeUIView(context: UIViewRepresentableContext<YKTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = type
        return textField
    }

    func makeCoordinator() -> YKTextField.Coordinator {
        Coordinator(text: $text, placeholder: placeholder, on: onDone)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<YKTextField>) {
        uiView.text = text
        if isFirstResponder, !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var placeholder: String
        var didBecomeFirstResponder = false
        var onDone: (() -> Void)?

        init(text: Binding<String>, placeholder: String, on done: (() -> Void)?) {
            _text = text
            self.placeholder = placeholder
            onDone = done
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldDidEndEditing(_: UITextField) {
            if let onDone = onDone {
                onDone()
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
