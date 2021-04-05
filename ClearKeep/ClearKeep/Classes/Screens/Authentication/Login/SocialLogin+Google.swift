//
//  SocialLogin+Google.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/6/21.
//

import Foundation
import GoogleSignIn
import Firebase
import FirebaseAuth

// MARK: - Google Sign In
extension SocialLogin {
    
    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.topMostViewController()//  UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func signOutGoogleAccount() {
        GIDSignIn.sharedInstance().signOut()
    }
}
