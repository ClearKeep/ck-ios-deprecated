//
//  LoginViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/6/21.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    var loginResponseResult: Auth_AuthRes?
    var signInType: SocialLogin.SignInType?
}
