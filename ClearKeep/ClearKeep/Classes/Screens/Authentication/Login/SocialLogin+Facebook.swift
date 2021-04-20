//
//  SocialLogin+Facebook.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/19/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

// MARK: - Google Sign In
extension SocialLogin {
    
    func attemptLoginFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: nil) { (loginResult) in
            switch loginResult {
            case .cancelled:
                print("User canceled")
                return
            case .failed(let error):
                print("Failed to login: \(error.localizedDescription)")
                return
            case .success(let grantedPermissions, let deniedPermissions, let token):
                print("AccessToken: \(token?.tokenString ?? "")")
            }
        }
    }
    
    func signOutFacebookAccount() {
        
    }
}
