//
//  ProfileView.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/15/20.
//

import SwiftUI
import GoogleSignIn

struct ProfileView: View {

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var userName: String = "User name"
    @State var email: String = ""
    @State var phoneNumber: String = ""
    
    
    @State var isDisable: Bool = true
    @State var hudVisible = false
    @State var emailDisable = true
    @State var userNameDisable = false
    @State var phoneNumberDisable = false
    @State var isToggleOn = false
    
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State var titleAlert = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        userProfilePicture()
                        
                        TextFieldProfile("UserName", header: "Username", text: $userName, disable: $userNameDisable) { (_) in }
                        
                        TextFieldProfile("Email", header: "Email", keyboardType: .emailAddress, text: $email, disable: $emailDisable) { (_) in }
                        
                        TextFieldProfile("Phone Number", header: "Phone Number", keyboardType: .phonePad, text: $phoneNumber, disable: $phoneNumberDisable) { (_) in }
                        
                        NavigationLink(destination:
                                        ChangePasswordView(viewModel: ChangePasswordViewModel())
                        ) {
                            HStack {
                                Text("Change Password")
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.primary.color)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                Image("arrow-right")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16, alignment: .center)
                                    .foregroundColor(AppTheme.colors.primary.color)
                            }
                        }
                        
                        twoFactorAuthView()
                    }
                }
            }
            .padding([.trailing , .leading , .bottom] , 16)
            .applyNavigationBarGradidentStyle(title: "Profile Settings", leftBarItems: {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("ic_close")
                        .frame(width: 24, height: 24)
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
            }, rightBarItems: {
                Button(action: saveInfo) {
                    Text("Save")
                        .font(AppTheme.fonts.linkMedium.font)
                        .foregroundColor(AppTheme.colors.primary.color)
                }
            })
            
            Spacer()
        }
        .keyboardManagment()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(self.titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("OK")))
        })
        .onAppear() {
            if let userLogin = Backend.shared.getUserLogin() {
                self.email = userLogin.email
                self.userName = userLogin.displayName
                self.phoneNumber = ""
                
                let dictOTP = UserDefaults.standard.dictionary(forKey: "OTPEnableInfoKey") as? [String:Bool] ?? [:]
                self.isToggleOn = dictOTP[userLogin.id] ?? false
            }
        }
    }
    
    private func showPhoneNumberAlert() {
        titleAlert = "Type in your phone number"
        messageAlert = "You must input your phone number in order to enable this feature."
        isShowAlert = true
    }
    
    private func userProfilePicture() -> some View {
        HStack(spacing: 10) {
            ChannelUserAvatar(avatarSize: 64, statusSize: 8, text: userName.capitalized, image: nil, status: .none, gradientBackgroundType: .primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Change profile picture")
                    .font(AppTheme.fonts.linkSmall.font)
                    .foregroundColor(AppTheme.colors.primary.color)
                    .lineLimit(2)
                
                Text("Maximum fize size 5MB")
                    .font(AppTheme.fonts.textXSmall.font)
                    .foregroundColor(AppTheme.colors.gray3.color)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func twoFactorAuthView() -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Two Factors Authentication")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.black.color)
                
                Text("Give your account more protection over scam and account hacking")
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.gray2.color)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Toggle("", isOn: $isToggleOn)
                .frame(maxWidth: 60)
                .padding(.trailing, 2)
        }
        .padding(.vertical, 4)
        
    }
    
    private func saveInfo() {
        self.hideKeyboard()
        
        if isToggleOn && phoneNumber.isEmpty {
            showPhoneNumberAlert()
        } else {
            // TODO: update info to server
            if let userLogin = Backend.shared.getUserLogin() {
                var dictOTP = UserDefaults.standard.dictionary(forKey: "OTPEnableInfoKey") as? [String:Bool] ?? [:]
                dictOTP[userLogin.id] = isToggleOn
                UserDefaults.standard.setValue(dictOTP, forKey: "OTPEnableInfoKey")
                UserDefaults.standard.synchronize()
            }
            
            titleAlert = "Action is pending"
            messageAlert = "Server is not ready at the moment."
            isShowAlert = true
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
