//
//  ShareButtons.swift
//  YourKitchen
//
//  Created by Markus Moltke on 18/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import FASwiftUI
import FBSDKShareKit
import MessageUI
import SwiftUI

struct ShareButtons: View {
    @State var showingSheet = false
    @State var showingShare = false

    @Binding var recipe: Recipe
    var msgComposer = MessageComposerDelegate()

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ShareButton(action: {
                        self.showingShare = true
                    }, image: FAText(iconName: "paper-plane", size: 20, style: .solid)
                        .foregroundColor(Color.white), title: "This", backgroundColor: Color.orange)
                    ShareButton(action: {
                        let content = ShareLinkContent()
                        content.contentURL = URL(string: "https://yourkitchen.page.link/viewRecipe?id=" + self.recipe.id)!

                        let messageDialog = MessageDialog()
                        messageDialog.shareContent = content

                        if messageDialog.canShow {
                            messageDialog.show()
                        }
                    }, image: FAText(iconName: "facebook-messenger", size: 20)
                        .foregroundColor(Color.white), title: "Messenger", backgroundColor: Color.blue)
                    ShareButton(action: {
                        self.presentMessageCompose()
                    }, image: FAText(iconName: "comment", size: 20, style: .solid)
                        .font(.system(size: 20.0))
                        .foregroundColor(Color.white),
                    title: "SMS", backgroundColor: Color.green)
                    ShareButton(action: {
                        let content = ShareLinkContent()
                        content.contentURL = URL(string: "https://yourkitchen.page.link/viewRecipe?id=" + self.recipe.id)!
                        let shareDialog = ShareDialog()
                        shareDialog.shareContent = content
                        shareDialog.mode = .automatic
                        if shareDialog.canShow {
                            shareDialog.show()
                        }
                    }, image: FAText(iconName: "facebook-f", size: 20)
                        .font(.system(size: 20.0))
                        .foregroundColor(Color.white),
                    title: "Facebook", backgroundColor: AppConstants.Colors.facebookColor)
                    ShareButton(action: {
                        self.showingSheet = true
                    }, image: FAText(iconName: "ellipsis-h", size: 20)
                        .foregroundColor(Color.white),
                    title: "Other", backgroundColor: Color.yellow)
                }.padding()
            }
            NavigationLink(destination: ShareView(recipe: self.recipe), isActive: self.$showingShare) {
                EmptyView()
            }
        }
        .sheet(isPresented: self.$showingSheet) {
            ActivityView(activityItems: [URL(string: "https://yourkitchen.page.link/viewRecipe?id=" + self.recipe.id)!] as [Any],
                         applicationActivities: nil)
        }
    }
}

extension ShareButtons {
    class MessageComposerDelegate: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith _: MessageComposeResult) {
            // Customize here
            controller.dismiss(animated: true)
        }
    }

    /// Present an message compose view controller modally in UIKit environment
    func presentMessageCompose() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        let vc = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = msgComposer

        composeVC.body = "https://yourkitchen.page.link/viewRecipe?id=" + recipe.id

        vc?.present(composeVC, animated: true)
    }
}

struct ShareButtons_Previews: PreviewProvider {
    static var previews: some View {
        ShareButtons(recipe: .constant(Recipe.none))
    }
}
