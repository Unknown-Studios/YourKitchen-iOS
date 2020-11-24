//
//  ContentView.swift
//  iOS-Template
//
//  Created by Markus Moltke on 23/04/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import AuthenticationServices
import FBSDKLoginKit
import Firebase
import SwiftUI

struct LoginView: View {
    var loginModel = SocialLoginViewModel()

    @State var presentAlert = false
    @State var alertText: String = ""
    @State var loading = true
    @State var showOnboarding = false
    @State var loadingMessage = "Loading.."
    
    @Binding var user: YKUser?

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    

    @ViewBuilder var body: some View {
        LoadingView(title: self.loadingMessage, loading: self.$loading) {
            VStack {
                if (self.showOnboarding) {
                    OnboardingView(showing: self.$showOnboarding)
                } else if (self.user == nil) {
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            SocialLoginButton(type: .facebook)
                                .frame(width: 280, height: 45)
                                .background(AppConstants.Colors.facebookColor)
                                .cornerRadius(5.0)
                                .onTapGesture {
                                    self.login(type: .facebook)
                            }
                            LabelledDivider(label: "or")
                            SocialLoginButton(type: .google)
                                .frame(width: 280, height: 45)
                                .background(RoundedRectangle(cornerRadius: 5.0)
                                    .fill((self.colorScheme == .light) ? Color.white : AppConstants.Colors.googleColor)
                                    .shadow(radius: (self.colorScheme == .light) ? 4.0 : 0.0))
                                .onTapGesture {
                                    self.login(type: .google)
                            }
                            LabelledDivider(label: "or")
                            SignInWithAppleButton()
                                .frame(width: 280, height: 45)
                                .padding(.bottom, 50)
                                .onTapGesture {
                                    self.login(type: .apple)
                            }
                        }.frame(width: 300)
                        Spacer()
                    }
                } else {
                    MainView()
                }
            }
        }.onDisappear(perform: {
            self.loading = false
            self.loadingMessage = "Loading.."
        }).onAppear {
            self.followUserState()
            self.checkOnboarding()
            if (CommandLine.arguments.contains("-uiTesting")) {
                self.loading = true
                self.loadingMessage = "Loading test user.."
                loginModel.testSignIn { (success) in
                    self.loading = false
                    print(success.description)
                }
            }
            Analytics.logEvent(AnalyticsEventScreenView,
                               parameters: [AnalyticsParameterScreenName: "Login",
                                            AnalyticsParameterScreenClass: LoginView.self])
        }.alert(isPresented: self.$presentAlert) {
            Alert(title: Text("Error"), message: Text(self.alertText), dismissButton: .cancel(Text("Okay")))
        }
    }
    
    func followUserState() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.loadingMessage = "Setting user.."
            print("Setting user: " + (user != nil).description)
            if user != nil {
                YKNetworkManager.Users.get { user in
                    self.loadingMessage = "User gotten"
                    self.user = user
                    self.loading = false
                }
            } else if !CommandLine.arguments.contains("-uiTesting") {
                self.user = nil
                self.loading = false
            }
        }
    }
    
    func checkOnboarding() {
        let onboardingDone = UserDefaults.standard.bool(forKey: "onboardingDone")
        let privacyConsent = UserDefaults.standard.bool(forKey: "privacyConsent")
        if !privacyConsent || !onboardingDone {
            // Request ad consent and privacyConsent
            showOnboarding = true
        }
    }

    private func login(type: LoginType) {
        self.loading = true
        loginModel.login(type: type) { (user, err) in
            self.loading = false
            if let err = err {
                if type == .facebook {
                    let loginManager = LoginManager()
                    loginManager.logOut() // this is an instance function
                }
                if err != "" {
                    self.alertText = err
                    self.presentAlert = true
                }
            } else {
                print("Login succesful")
            }
        }
    }
}
