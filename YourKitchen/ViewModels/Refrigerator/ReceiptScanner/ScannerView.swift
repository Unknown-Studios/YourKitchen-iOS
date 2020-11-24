//
//  ScannerView.swift
//  YourKitchen
//
//  Created by Markus Moltke on 14/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    private let completionHandler: ([String]?) -> Void

    init(completion: @escaping ([String]?) -> Void) {
        completionHandler = completion
    }

    typealias UIViewControllerType = VNDocumentCameraViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_: VNDocumentCameraViewController, context _: UIViewControllerRepresentableContext<ScannerView>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completionHandler)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: ([String]?) -> Void

        init(completion: @escaping ([String]?) -> Void) {
            completionHandler = completion
        }

        func documentCameraViewController(_: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Document camera view controller did finish with ", scan)
            let recognizer = TextRecognizer(cameraScan: scan)
            recognizer.recognizeText(withCompletionHandler: completionHandler)
        }

        func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            completionHandler(nil)
        }

        func documentCameraViewController(_: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera view controller did finish with error ", error)
            completionHandler(nil)
        }
    }
}
