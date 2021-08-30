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
        guard let first = customServerURL.components(separatedBy: ":").first,
              let last = customServerURL.components(separatedBy: ":").last else {
            return false
        }
        
        let validated = first.textFieldValidatorURL() && (first != last) && customServerURL.last! != ":"

        return validated
    }
}
