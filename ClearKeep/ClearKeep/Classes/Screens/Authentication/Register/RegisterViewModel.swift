//
//  RegisterViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import Foundation

class RegisterViewModel: ObservableObject {
   
    init() {}
    
    @Published var email: String = ""
    @Published var userName: String = ""
    @Published var passWord: String = ""
    @Published var passWordConfirm: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    @Published var errorMsgEmail: String = ""
    @Published var errorMsgDisplayName: String = ""
    @Published var errorMsgPassword: String = ""
    @Published var errorMsgConfirmPwd: String = ""
    
    @Published var hudVisible = false
    @Published var isShowAlert = false
    @Published var messageAlert = ""
    @Published var titleAlert = ""
    @Published var isRegisterSuccess: Bool = false

    @Published var isEmailValid : Bool = true
    @Published var isDisplayNameValid: Bool = true
    @Published var isPasswordValid : Bool = true
    @Published var isConfirmPasswordValid : Bool = true

    @Published var emailIsFocused: Bool = false {
        didSet {
            if emailIsFocused {
                errorMsgEmail = ""
            } else {
                verifyEmail()
            }
        }
    }
    
    @Published var userNameIsFocused: Bool = false {
        didSet {
            if userNameIsFocused {
                errorMsgDisplayName = ""
            } else {
                verifyUsername()
            }
        }
    }
    
    @Published var passWordIsFocused: Bool = false {
        didSet {
            if passWordIsFocused {
                errorMsgPassword = ""
            } else {
                verifyPassword()
            }
        }
    }
    
    @Published var passWordConfirmIsFocused: Bool = false {
        didSet {
            if passWordConfirmIsFocused {
                errorMsgConfirmPwd = ""
            } else {
                verifyConfirmPassword()
            }
        }
    }
    
    fileprivate func verifyEmail() {
        isEmailValid = email.textFieldValidatorEmail()
        if email.isEmpty {
            errorMsgEmail = "This field cannot be empty"
        } else {
            errorMsgEmail = isEmailValid ? "" : "Email is incorrect"
        }
    }
    
    fileprivate func verifyUsername() {
        isDisplayNameValid = !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if userName.isEmpty {
            errorMsgDisplayName = "This field cannot be empty"
        } else {
            errorMsgDisplayName = isDisplayNameValid ? "" : "Invalid display name"
        }
    }
    
    fileprivate func verifyPassword() {
        let pwd = passWord.trimmingCharacters(in: .whitespacesAndNewlines)
        isPasswordValid = !pwd.isEmpty && pwd.count >= 6
        if isPasswordValid {
            errorMsgPassword = ""
        } else if pwd.isEmpty {
            errorMsgPassword = "Password must not be blank"
        } else {
            errorMsgPassword = "Password must have at least 6 characters"
        }
    }
    
    fileprivate func verifyConfirmPassword() {
        let confirmPwd = passWordConfirm.trimmingCharacters(in: .whitespacesAndNewlines)
        isConfirmPasswordValid = !confirmPwd.isEmpty && passWordConfirm == passWord
        if isConfirmPasswordValid {
            errorMsgConfirmPwd = ""
        } else if confirmPwd.isEmpty {
            errorMsgConfirmPwd = "This field cannot be empty"
        } else {
            errorMsgConfirmPwd = "Password and Confirm password do not match"
        }
    }
}

extension RegisterViewModel {
   
    func register(){
        verifyEmail()
        verifyUsername()
        verifyPassword()
        verifyConfirmPassword()
    
        guard self.isEmailValid && self.isDisplayNameValid && self.isPasswordValid && self.isConfirmPasswordValid else {
            self.messageAlert = "Please check the input data again"
            self.titleAlert = "Register Error"
            self.isShowAlert = true
            return
        }
           
        hudVisible = true
        
        var request = Auth_RegisterReq()
        request.displayName = self.userName
        request.password = self.passWord
        request.email = self.email
        request.firstName = self.firstName
        request.lastName = self.lastName
        
        Backend.shared.register(request) { (result , error) in
            self.hudVisible = false
            if let result = result {
                if result.baseResponse.success {
                    self.isRegisterSuccess = true
                    self.messageAlert = "Please check your email to activate account"
                    self.titleAlert = "Register Successfully"
                    self.isShowAlert = true
                } else {
                    self.titleAlert = "Register Error"
                    self.messageAlert = result.baseResponse.errors.message
                    self.isShowAlert = true
                }
            } else {
                self.titleAlert = "Register Error"
                self.messageAlert = error.debugDescription
                self.isShowAlert = true
                print("Register account fail")
            }
        }
    }
}
