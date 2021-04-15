//
//  RegisterView.swift
//  ClearKeep
//
//  Created by Seoul on 11/12/20.
//

import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var isPresentModel: Bool
    
    @ObservedObject var viewModel = RegisterViewModel()

    var body: some View {
        VStack {
            GeometryReader { reader in
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack {
                        LogoIconView()
                            .padding(.top , 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Please fill in the information below to complete your sign up")
                                .font(AppTheme.fonts.textMedium.font)
                                .foregroundColor(AppTheme.colors.black.color)
                            
                            WrappedTextFieldWithLeftIcon("Email", leftIconName: "Mail", text: $viewModel.email, errorMessage: $viewModel.errorMsgEmail, isFocused: $viewModel.emailIsFocused)
                            
                            WrappedTextFieldWithLeftIcon("Display Name", leftIconName: "User-check", text: $viewModel.userName, errorMessage: $viewModel.errorMsgDisplayName, isFocused: $viewModel.userNameIsFocused)
                            
                            WrappedSecureTextWithLeftIcon("Password",leftIconName: "Lock", text: $viewModel.passWord, errorMessage: $viewModel.errorMsgPassword, isFocused: $viewModel.passWordIsFocused)
                            
                            WrappedSecureTextWithLeftIcon("Confirm Password",leftIconName: "Lock", text: $viewModel.passWordConfirm, errorMessage: $viewModel.errorMsgConfirmPwd, isFocused: $viewModel.passWordConfirmIsFocused)
                            
                            HStack {
                                PlainButton("Sign in instead") {
                                    self.isPresentModel = false
                                }
                                
                                Spacer()
                                
                                RoundedGradientButton("Sign up", fixedWidth: 120, action: {
                                    UIApplication.shared.endEditing()
                                    self.viewModel.register()
                                })
                            }
                            .padding(.top, 10)
                        }
                        .padding(.vertical, 10)
                        .embededInCardView()
                    }
                    .padding()
                    .padding(.vertical, 20)
                })
                
            }
        }
        .navigationBarHidden(true)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.endEditing()
                })
        .hud(.waiting(.circular, "Waiting..."), show: viewModel.hudVisible)
        .alert(isPresented: $viewModel.isShowAlert, content: {
            Alert(title: Text(self.viewModel.titleAlert),
                  message: Text(self.viewModel.messageAlert),
                  dismissButton: .default(Text("OK"), action: {
                    if viewModel.isRegisterSuccess {
                        isPresentModel = false
                    }
                  }))
        })
        .keyboardAdaptive()
        .grandientBackground()
    }
}


struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isPresentModel: .constant(true))
    }
}
