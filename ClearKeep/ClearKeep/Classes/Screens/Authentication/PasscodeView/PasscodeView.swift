//
//  PasscodeView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/5/21.
//

import SwiftUI

struct PasscodeView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var passCodeModel : PassCodeInputModel
    
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State var titleAlert = ""
    
    @State var isPassCodeVerified = false
    
    var passCode: String
    var successCompletion: VoidCompletion
    
    init(passCode: String = "1111", passCodeModel : PassCodeInputModel, successCompletion: @escaping VoidCompletion) {
        self.passCode = passCode
        self.passCodeModel = passCodeModel
        self.successCompletion = successCompletion
    }
    
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
                    Text("Enter Your OTP")
                        .fontWeight(.bold)
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                }.padding(.top, 59)
                
                Text("Please input a code that has been sent to your phone")
                    .fontWeight(.medium)
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.background.color)
                    .padding(.top, 20)
                
                PassCodeInputField(inputModel: self.passCodeModel)
                    .padding(.vertical, 16)
                    .onReceive([self.passCodeModel.isValid].publisher.first()) { value in
                        if value && !isPassCodeVerified {
                            checkInputtedPasscode()
                        }
                    }
                
                HStack() {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("Don’t get the code?")
                            .font(AppTheme.fonts.textMedium.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                        
                        Button(action: resendCode) {
                            Text("Resend Code")
                                .font(AppTheme.fonts.linkMedium.font)
                                .foregroundColor(AppTheme.colors.offWhite.color)
                            
                        }
                    }
                    Spacer()
                }
                
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
                    self.hideKeyboard()
                }
        )
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .alert(isPresented: $isShowAlert, content: {
            Alert(title: Text(titleAlert),
                  message: Text(messageAlert),
                  dismissButton: .default(Text("Close")))
        })
    }
    
    private func resendCode() {
        self.hideKeyboard()
        hudVisible = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hudVisible = false
            self.isShowAlert = true
            self.titleAlert = "Action failed"
            self.messageAlert = "The server is not ready now"
        }
    }
    
    private func checkInputtedPasscode() {
        print(passCodeModel.passCodeString)
        if passCodeModel.passCodeString == passCode {
            self.isPassCodeVerified = true
            self.presentationMode.wrappedValue.dismiss()
            successCompletion()
        } else {
            self.isShowAlert = true
            self.titleAlert = "Wrong code"
            self.messageAlert = "Please try again"
        }
    }
}

struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeView(passCodeModel: PassCodeInputModel(passCodeLength: 4), successCompletion: {})
    }
}
