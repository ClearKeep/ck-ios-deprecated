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
        ZStack {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Image("ic_back_white")
                        .frame(width: 40, height: 40)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .fixedSize()
                        .scaledToFit()
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.isPresentModel = false
                        })
                    Text("Forgot password")
                        .fontWeight(.bold)
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                }.padding(.top, 59)
                
                Text("Please enter your email to reset your password")
                    .fontWeight(.medium)
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray5.color)
                    .padding(.top, 26)
                
                TextFieldWithLeftIcon("Email", leftIconName: "Mail", text: $email) { _ in  }
                    .padding(.top, 16)
                
                ButtonAuth("Reset password") {
                    forgotPassword()
                }.padding(.top, 24)
                
                Spacer()
                
            }
        }
        .padding(16)
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .grandientBackground()
        .gesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.endEditing()
                })
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
                self.messageAlert = "Something went wrong"
                self.isShowAlert = true
            }
        }
    }
}

