//
//  SocialLogin+MSAL.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/6/21.
//

import Foundation
import MSAL

// MARK: - Login using MSAL
extension SocialLogin {
    func configMSAL() {
        do {
            try self.initMSAL()
        } catch let error {
            print("Unable to create Application Context \(error)")
        }
    }

    func initMSAL() throws {
        guard let authorityURL = URL(string: kAuthority) else {
            print("Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController:
                                                        UIApplication.shared.topMostViewController()!)
    }

    
    // Tap on call graph button
    func attemptLoginOffice365() {
        guard let account = try? applicationContext?.allAccounts().first else {
            self.acquireTokenInteractively()
            return
        }
        
        self.acquireTokenSilently(account)
    }
    
    func acquireTokenInteractively() {
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                print("Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                print("Could not acquire token: No result returned")
                return
            }
            
            self.getFetchedMicrosoftAccessToken(result.accessToken)
        }
    }
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                print("Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                print("Could not acquire token: No result returned")
                return
            }
            
            self.getFetchedMicrosoftAccessToken(result.accessToken)
        }
    }
    
    func getFetchedMicrosoftAccessToken(_ accessToken: String) {
        self.microsoftAccessToken = accessToken
        print("Access token is \(self.microsoftAccessToken)")
        
        let userInfo: [String : Any] = ["accessToken": accessToken]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.MicrosoftSignIn.FinishedWithResponse,
                                            object: nil,
                                            userInfo: userInfo)
        }
    }
    
    func getGraphEndpoint() -> String {
        return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
    }
}

// MARK: - MSAL: Get account and removing cache

extension SocialLogin {
    
    /**
     This action will invoke the remove account APIs to clear the token cache
     to sign out a user from this application.
     */
    func signOutO365() {
        guard let applicationContext = self.applicationContext else { return }
        
        let accounts = try? applicationContext.allAccounts()
        guard let account = accounts?.first else { return }
        
        try? applicationContext.remove(account)
    }
}
