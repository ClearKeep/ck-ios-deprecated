//
//  ChangePasswordViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/5/21.
//

import Foundation

class ChangePasswordViewModel: ObservableObject {
   
    init() {}
    
    @Published var hudVisible = false
    
    @Published var isShowAlert = false
    @Published var messageAlert = ""
    @Published var titleAlert = ""
    
    @Published var passWord: String = "" {
        didSet {
            errorMsgPassword = ""
        }
    }
    
    @Published var newPassWord: String = "" {
        didSet {
            errorMsgNewPassword = ""
        }
    }
    
    @Published var passWordConfirm: String = "" {
        didSet {
            errorMsgConfirmPwd = ""
        }
    }
    
    @Published var errorMsgPassword: String = ""
    @Published var errorMsgNewPassword: String = ""
    @Published var errorMsgConfirmPwd: String = ""
    
    @Published var isPasswordValid : Bool = true
    @Published var isNewPasswordValid : Bool = true
    @Published var isConfirmPasswordValid : Bool = true
    
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

    fileprivate func verifyNewPassword() {
        let pwd = newPassWord.trimmingCharacters(in: .whitespacesAndNewlines)
        isNewPasswordValid = !pwd.isEmpty && pwd.count >= 6
        if isNewPasswordValid {
            errorMsgNewPassword = ""
        } else if pwd.isEmpty {
            errorMsgNewPassword = "New password must not be blank"
        } else {
            errorMsgNewPassword = "New password must have at least 6 characters"
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

extension ChangePasswordViewModel {
   
    func updatePassword(){
        verifyPassword()
        verifyNewPassword()
        verifyConfirmPassword()
    
        guard self.isPasswordValid && self.isNewPasswordValid && self.isConfirmPasswordValid else {
            self.messageAlert = "Please check the input data again"
            self.titleAlert = "Change Password Error"
            self.isShowAlert = true
            return
        }
        
        // TODO: call API
        
        self.messageAlert = "The server is not ready now"
        self.titleAlert = "Change Password Failed"
        self.isShowAlert = true
    }
}
