//
//  ForgotPassWordView.swift
//  ClearKeep
//
//  Created by Seoul on 1/29/21.
//

import SwiftUI

struct ForgotPassWordView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email: String = ""
    @Binding var isPresentModel: Bool
    @State private var isEmailValid : Bool = true
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State var titleAlert = ""

    var body: some View {
        VStack {
            TitleLabel("Forgot Password")
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
                Text("Email is Not Valid")
                    .font(Font.system(size: 13))
                    .foregroundColor(Color.red)
            }
            
            
            Button(action: forgotPassword) {
                ButtonContent("Send").padding()
            }
        }
        .padding()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("OK")))
        })
    }
}

extension ForgotPassWordView {
    private func forgotPassword(){
        if !isEmailValid {
            return
        }
        hudVisible = true
            
        Backend.shared.forgotPassword(email: self.email) { (result, isSuccess) in
            hudVisible = false
            if isSuccess {
                if let result = result {
                    if result.success {
                        self.titleAlert = "Email is sent successfully"
                        self.messageAlert = "Please check your email to reset password"
                        self.isShowAlert = true
                    } else {
                        self.titleAlert = "Forgot Pasword Error"
                        self.messageAlert = result.errors.message
                        self.isShowAlert = true
                    }
                }
            } else {
                self.titleAlert = "Forgot Pasword Error"
                self.messageAlert = "Something when wrong"
                self.isShowAlert = true
            }
        }
    }
}

