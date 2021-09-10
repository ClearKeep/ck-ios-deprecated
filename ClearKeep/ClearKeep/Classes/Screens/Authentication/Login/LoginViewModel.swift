//
//  LoginViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/6/21.
//

import Foundation

struct UserLoginResponseInfo {
    let userId: String
    let userDisplayName: String
    let userEmail: String
    let signInType: SocialLogin.SignInType
}

class LoginViewModel: ObservableObject {
    @Published var isUseCustomServer = false
    @Published var customServerURL = ""
    
    var userLoginResponseInfo = UserLoginResponseInfo(userId: "", userDisplayName: "", userEmail: "", signInType: .email)
    
    func usedCustomServer() -> Bool {
        let (host, port) = getWorkspaceDomain(customServerURL)
        if host.isEmpty || host.isEmpty { return false }
        let validated = host.textFieldValidatorURL() && (host != port) && port != ":"

        return validated
    }
    
    private func getWorkspaceDomain(_ url: String) -> (String, String) {
        if !url.contains(":") { return (url, "") }
        
        let host = url.components(separatedBy: ":").first ?? ""
        let port = url.components(separatedBy: ":").last ?? ""
        
        return (host,port)
    }
}
