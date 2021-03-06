//
//  YKTakePhoto.swift
//  YourKitchen
//
//  Created by Markus Moltke on 02/07/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import SwiftUI

struct YKTakePhoto: UIViewControllerRepresentable {
    @Environment(\.presentationMode)
    var presentationMode

    @Binding var image: UIImage?
    var completion: () -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var image: UIImage?
        var completion: () -> Void

        init(presentationMode: Binding<PresentationMode>, image: Binding<UIImage?>, completion: @escaping () -> Void) {
            print("takephoto")
            _presentationMode = presentationMode
            _image = image
            self.completion = completion
        }

        func imagePickerController(_: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                image = uiImage
                completion()
                presentationMode.dismiss()
            }
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(presentationMode: presentationMode, image: $image, completion: completion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<YKTakePhoto>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
        }
        return picker
    }

    func updateUIViewController(_: UIImagePickerController,
                                context _: UIViewControllerRepresentableContext<YKTakePhoto>) {}
}
