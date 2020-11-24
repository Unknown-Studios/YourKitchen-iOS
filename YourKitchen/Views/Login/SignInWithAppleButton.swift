//
//  SignInWithAppleButton.swift
//  YourKitchen
//
//  Created by Markus Moltke on 03/06/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import AuthenticationServices
import FASwiftUI
import SwiftUI

// Implementation courtesy of https://stackoverflow.com/a/56852456/281221
struct SignInWithAppleButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme // (1)

    var body: some View {
        Group {
            if colorScheme == .light { // (2)
                SignInWithAppleButtonInternal(colorScheme: .light)
            } else {
                SignInWithAppleButtonInternal(colorScheme: .dark)
            }
        }
    }
}

private struct SignInWithAppleButtonInternal: UIViewRepresentable { // (3)
    var colorScheme: ColorScheme

    func makeUIView(context _: Context) -> ASAuthorizationAppleIDButton {
        switch colorScheme {
        case .light:
            return ASAuthorizationAppleIDButton(type: .signIn, style: .black) // (4)
        case .dark:
            return ASAuthorizationAppleIDButton(type: .signIn, style: .white) // (5)
        @unknown default:
            return ASAuthorizationAppleIDButton(type: .signIn, style: .black) // (6)
        }
    }

    func updateUIView(_: ASAuthorizationAppleIDButton, context _: Context) {}
}

public enum SocialType {
    case facebook
    case google
}

struct SocialLoginButton: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme // (1)

    var type: SocialType

    var body: some View {
        Group {
            if type == .facebook {
                HStack {
                    FAText(iconName: "facebook-f", size: 18.0)
                        .foregroundColor(Color.white)
                    Text("Sign in with Facebook")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18.0))
                }
            } else if type == .google {
                HStack {
                    Image("GoogleLogo")
                        .resizable()
                        .frame(width: 18.0, height: 18.0)
                    Text("Sign in with Google".uppercased())
                        .font(Font.custom("Roboto-Medium", size: 15.0))
                }
            } else {
                EmptyView()
            }
        }
    }
}
