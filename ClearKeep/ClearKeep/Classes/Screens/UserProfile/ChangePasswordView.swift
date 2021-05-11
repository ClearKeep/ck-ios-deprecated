//
//  ChangePasswordView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/5/21.
//

import SwiftUI

struct ChangePasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ChangePasswordViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Please enter your details to change password")
                .fontWeight(.medium)
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.background.color)
                .padding(.top, 20)
            
            CustomSecureTextWithLeftIcon("Current Password", leftIconName: "Lock", text: $viewModel.passWord, errorMessage: $viewModel.errorMsgPassword)
            
            CustomSecureTextWithLeftIcon("New Password", leftIconName: "Lock", text: $viewModel.newPassWord, errorMessage: $viewModel.errorMsgNewPassword)
            
            CustomSecureTextWithLeftIcon("Confirm Password", leftIconName: "Lock", text: $viewModel.passWordConfirm, errorMessage: $viewModel.errorMsgConfirmPwd)
            
            ButtonAuth("Save") {
                self.hideKeyboard()
                viewModel.updatePassword()
            }.padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .applyNavigationBarPlainStyleLight(title: "Enter Your New Password", leftBarItems: {
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
        .hud(.waiting(.circular, "Waiting..."), show: viewModel.hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
        .alert(isPresented: $viewModel.isShowAlert, content: {
            Alert(title: Text(viewModel.titleAlert),
                  message: Text(viewModel.messageAlert),
                  dismissButton: .default(Text("Close")))
        })
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(viewModel: ChangePasswordViewModel())
    }
}
