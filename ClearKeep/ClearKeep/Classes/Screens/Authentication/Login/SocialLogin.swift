//
//  SocialLogin.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/31/21.
//

import SwiftUI
import GoogleSignIn


// Sign-In flow UI of the provider
struct SocialLogin: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<SocialLogin>) -> UIView {
        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<SocialLogin>) {
    }

    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.topMostViewController()//  UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func signOutGoogleAccount() {
        GIDSignIn.sharedInstance().signOut()
    }
}
