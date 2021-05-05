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
        ZStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 16) {
                    Image("ic_back_white")
                        .frame(width: 40, height: 40)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .fixedSize()
                        .scaledToFit()
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    Text("Enter Your New Password")
                        .fontWeight(.bold)
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                }.padding(.top, 59)
                
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
        .hud(.waiting(.circular, "Waiting..."), show: viewModel.hudVisible)
        .alert(isPresented: $viewModel.isShowAlert, content: {
            Alert(title: Text(viewModel.titleAlert),
                  message: Text(viewModel.messageAlert),
                  dismissButton: .default(Text("Close")))
        })
    }
    
    private func updatePassword() {
        
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(viewModel: ChangePasswordViewModel())
    }
}
