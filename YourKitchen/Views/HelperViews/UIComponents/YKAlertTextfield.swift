//
//  YKAlertTextfield.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct YKAlertTextfield: UIViewControllerRepresentable {
    @Binding var textString: String
    @Binding var show: Bool
    var doneClicked: (String) -> Void

    var title: String
    var message: String

    func makeUIViewController(context _: UIViewControllerRepresentableContext<YKAlertTextfield>) -> UIViewController {
        UIViewController() // holder controller - required to present alert
    }

    func updateUIViewController(_ viewController: UIViewController, context: UIViewControllerRepresentableContext<YKAlertTextfield>) {
        guard context.coordinator.alert == nil else { return }
        if show {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            context.coordinator.alert = alert

            alert.addTextField { textField in
                textField.placeholder = "Enter some text"
                textField.text = self.textString // << initial value if any
                textField.delegate = context.coordinator // << use coordinator as delegate
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in
                // your action here
            })
            alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
                let textField = alert.textFields![0] as UITextField
                self.doneClicked(textField.text ?? "")
            })

            DispatchQueue.main.async { // must be async !!
                viewController.present(alert, animated: true, completion: {
                    self.show = false // hide holder after alert dismiss
                    context.coordinator.alert = nil
                })
            }
        }
    }

    func makeCoordinator() -> YKAlertTextfield.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var alert: UIAlertController?
        var control: YKAlertTextfield
        init(_ control: YKAlertTextfield) {
            self.control = control
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text as NSString? {
                control.textString = text.replacingCharacters(in: range, with: string)
            } else {
                control.textString = ""
            }
            return true
        }
    }
}
