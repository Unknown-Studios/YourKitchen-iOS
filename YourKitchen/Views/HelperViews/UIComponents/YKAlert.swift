//
//  YKAlertTextfield.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/05/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct YKAlert: UIViewControllerRepresentable {

    @Binding var show: Bool

    var title: String
    var message: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<YKAlert>) -> UIViewController {
        return UIViewController() // holder controller - required to present alert
    }

    func updateUIViewController(_ viewController: UIViewController, context: UIViewControllerRepresentableContext<YKAlert>) {
        guard context.coordinator.alert == nil else { return }
        if self.show {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            context.coordinator.alert = alert
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { _ in
                // your action here
            })

            DispatchQueue.main.async { // must be async !!
                viewController.present(alert, animated: true, completion: {
                    self.show = false  // hide holder after alert dismiss
                    context.coordinator.alert = nil
                })
            }
        }
    }

    func makeCoordinator() -> YKAlert.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var alert: UIAlertController?
        var control: YKAlert
        init(_ control: YKAlert) {
            self.control = control
        }
    }
}
