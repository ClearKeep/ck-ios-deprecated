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
        loginManager.logOut()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: nil) { (loginResult) in
            switch loginResult {
            case .cancelled:
                print("User canceled")
                return
            case .failed(let error):
                print("Failed to login: \(error.localizedDescription)")
                let userInfo: [String : Any] = ["error": error]
                NotificationCenter.default.post(name: NSNotification.FacebookSignIn.FinishedWithError,
                                                object: nil,
                                                userInfo: userInfo)
                return
            case .success(let grantedPermissions, let deniedPermissions, let token):
                print("AccessToken: \(token?.tokenString ?? "")")
                if let accessToken = token?.tokenString {
                    self.getFetchedFacebookAccessToken(accessToken)
                }
            }
        }
    }
    
    func signOutFacebookAccount() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    func getFetchedFacebookAccessToken(_ accessToken: String) {
        print("Access token is \(accessToken)")
        
        let userInfo: [String : Any] = ["accessToken": accessToken]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.FacebookSignIn.FinishedWithResponse,
                                            object: nil,
                                            userInfo: userInfo)
        }
    }
}
