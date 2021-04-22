//
//  SocialLogin.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/31/21.
//

import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseAuth
import MSAL

class SocialLogin {
    private init() {
        configMSAL()
    }
    
    static let shared = SocialLogin()
    
    private static let signInTypeKey = "signInTypeKey"
    
    let microsoftProvider = OAuthProvider(providerID: "microsoft.com")
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    let ggSignInBtn: GIDSignInButton = GIDSignInButton()
    
    // MSAL params
    let kClientID = "8227879c-ae85-4f7b-8175-49ae0b2b6323"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kRedirectUri = "msauth.com.telred.clearkeep3.ios.dev://auth"
    let kScopes: [String] = ["user.read"]

    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var microsoftAccessToken = ""
}

extension SocialLogin {
    
    enum SignInType: Int {
        case email, google, microsoft, facebook
    }
    
    var currentSignInType: SignInType {
        let savedType = UserDefaults.standard.integer(forKey: SocialLogin.signInTypeKey)
        let type = SignInType(rawValue: savedType) ?? .email
        return type
    }
    
    func saveSignInType(_ type: SignInType?) {
        if let signInType = type {
            UserDefaults.standard.setValue(signInType.rawValue, forKey: SocialLogin.signInTypeKey)
        } else {
            UserDefaults.standard.removeObject(forKey: SocialLogin.signInTypeKey)
        }
        
        UserDefaults.standard.synchronize()
    }
}



// MARK: - Sign In Office365 via FireBase
extension SocialLogin {
    
    func attemptLoginOffice365ViaFireBase() {
        microsoftProvider.getCredentialWith(_: nil) { credential, error in
            if error != nil {
                // Handle error.
            }
            if let credential = credential {
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if error != nil {
                        // Handle error.
                    }
                    
                    guard let authResult = authResult else {
                        print("Couldn't get graph authResult")
                        return
                    }
                    
                    // get credential and token when login successfully
                    let microCredential = authResult.credential as! OAuthCredential
                    let token = microCredential.accessToken!
                    
                    // use token to call Microsoft Graph API
                    self.getGraphContentWithToken(accessToken: token)
                }
            }
        }
    }
    
    // function to call Microsoft Graph API by token
    func getGraphContentWithToken(accessToken: String) {
        
        // Specify the Graph API endpoint
        let url = URL(string: kGraphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                print("Couldn't deserialize result JSON")
                return
            }
            
            print("Result from Graph: \(result))")
            
        }.resume()
    }
}

