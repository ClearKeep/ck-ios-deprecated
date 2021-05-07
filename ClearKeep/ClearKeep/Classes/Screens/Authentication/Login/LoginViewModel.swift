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
    var userLoginResponseInfo = UserLoginResponseInfo(userId: "", userDisplayName: "", userEmail: "", signInType: .email)
}
