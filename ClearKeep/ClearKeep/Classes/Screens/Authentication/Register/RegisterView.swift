//
//  RegisterView.swift
//  ClearKeep
//
//  Created by Seoul on 11/12/20.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email: String = ""
    @State var userName: String = ""
    @State var passWord: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @Binding var isPresentModel: Bool
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State private var isEmailValid : Bool = true
    @State private var isDisplayNameValid: Bool = true
    @State private var isPasswordValid: Bool = true
    @State private var titleAlert = ""
    @State private var isRegisterSuccess: Bool = false
    
    var body: some View {
        VStack {
            TitleLabel("Register Account")
            TextField("Email", text: $email, onEditingChanged: { (isChanged) in
                if !isChanged {
                    self.isEmailValid = self.email.textFieldValidatorEmail()
                }
            })
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            if !self.isEmailValid {
                Text("Email is invalid")
                    .font(Font.system(size: 13))
                    .foregroundColor(Color.red)
            }
            TextField("Display Name", text: $userName , onEditingChanged: { (isChanged) in
                if !isChanged {
                    self.isDisplayNameValid = !self.userName.trimmingCharacters(in: .whitespaces).isEmpty
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            if !self.isDisplayNameValid {
                Text("Display name must not be blank")
                    .font(Font.system(size: 13))
                    .foregroundColor(Color.red)
            }
            TextField("Password", text: $passWord , onEditingChanged: { (isChanged) in
                if !isChanged {
                    self.isPasswordValid = !self.passWord.isEmpty
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            if !self.isPasswordValid {
                Text("Password must not be blank")
                    .font(Font.system(size: 13))
                    .foregroundColor(Color.red)
            }
            
            Button(action: register) {
                ButtonContent("REGISTER").padding()
            }
        }
        .padding()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(self.titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("OK"), action: {
                    if isRegisterSuccess {
                        isPresentModel = false
                    }
                  }))
        })
    }
}

extension RegisterView {
    private func register(){
        if !self.isEmailValid || !self.isDisplayNameValid {
            return
        } else if self.passWord.isEmpty {
            self.isPasswordValid = false
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
            hudVisible = false
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

