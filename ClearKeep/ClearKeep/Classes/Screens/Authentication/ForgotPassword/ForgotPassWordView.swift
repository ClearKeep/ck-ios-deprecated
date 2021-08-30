//
//  ForgotPassWordView.swift
//  ClearKeep
//
//  Created by Seoul on 1/29/21.
//

import SwiftUI

struct ForgotPassWordView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email: String = ""
    @State private var isEmailValid : Bool = true
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State var titleAlert = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please enter your email to reset your password")
                .fontWeight(.medium)
                .font(AppTheme.fonts.textMedium.font)
                .foregroundColor(AppTheme.colors.gray5.color)
                .padding(.top, 26)
            
            TextFieldWithLeftIcon("Email", leftIconName: "Mail", text: $email) { _ in  }
                .padding(.top, 16)
            
            DisableButton("Reset password", disable: .constant(email.isEmpty)) {
                forgotPassword()
            }.padding(.top, 24)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .applyNavigationBarPlainStyleLight(title: "Forgot password", leftBarItems: {
            Image("ic_back_white")
                .frame(width: 40, height: 40)
                .foregroundColor(AppTheme.colors.offWhite.color)
                .fixedSize()
                .scaledToFit()
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
        }, rightBarItems: {
            Spacer()
        })
        .grandientBackground()
        .onTapGesture {
            self.hideKeyboard()
        }
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("Close")))
        })
    }
}

extension ForgotPassWordView {
    private func forgotPassword(){
        self.isEmailValid = self.email.textFieldValidatorEmail()
        if !isEmailValid {
            self.titleAlert = "Email is incorrect"
            self.messageAlert = "Please check your details and try again"
            self.isShowAlert = true
            return
        }
        hudVisible = true
        
        Multiserver.instance.currentServer.forgotPassword(email: self.email) { (result, isSuccess) in
            hudVisible = false
            if isSuccess {
                if let result = result {
                    if result.success {
                        self.titleAlert = "Email is sent successfully"
                        self.messageAlert = "Please check your email to reset password"
                        self.isShowAlert = true
                    } else {
                        self.titleAlert = "Forgot Pasword Error"
                        self.messageAlert = result.error.message
                        self.isShowAlert = true
                    }
                }
            } else {
                self.titleAlert = "Forgot Pasword Error"
                self.messageAlert = "Something went wrong"
                self.isShowAlert = true
            }
        }
    }
}

