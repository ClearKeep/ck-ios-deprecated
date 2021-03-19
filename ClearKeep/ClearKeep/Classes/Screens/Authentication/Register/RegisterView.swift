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
    @State var passWordConfirm: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @Binding var isPresentModel: Bool
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State private var isEmailValid : Bool = true
    @State private var isDisplayNameValid: Bool = true
    @State private var titleAlert = ""
    @State private var isRegisterSuccess: Bool = false
    
    @State private var colorBorderEmail = Color.gray
    @State private var colorBorderDisplayName = Color.gray

    var body: some View {
        VStack {
            GeometryReader { reader in
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack {
                        Image("ic_app")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100, alignment: .center)
                            .padding(.top , 15)
                        
                        VStack(alignment:.leading, spacing: 10) {
                            
                            TitleTextField("Email")
                            TextField("", text: $email, onEditingChanged: { (isChanged) in
                                if !isChanged {
                                    self.isEmailValid = self.email.textFieldValidatorEmail()
                                    colorBorderEmail = self.isEmailValid ? Color.gray : Color.red
                                }
                            })
                            .font(.system(size: 20))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(colorBorderEmail, lineWidth: 1))
                            .textFieldStyle(MyTextFieldStyle())
                            .padding([.leading , .trailing], 1)
                            .onAppear {
                                self.isEmailValid = true
                            }
                            
                            if !self.isEmailValid {
                                Text("Email is invalid")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.red)
                            }
                            
                            TitleTextField("Display Name")
                                .padding(.top, 10)
                            TextField("", text: $userName , onEditingChanged: { (isChanged) in
                                if !isChanged {
                                    self.isDisplayNameValid = !self.userName.trimmingCharacters(in: .whitespaces).isEmpty
                                    colorBorderDisplayName = self.isDisplayNameValid ? Color.gray : Color.red
                                }
                            })
                            .font(.system(size: 20))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(colorBorderDisplayName, lineWidth: 1))
                            .textFieldStyle(MyTextFieldStyle())
                            .padding([.leading , .trailing], 1)
                            
                            if !self.isDisplayNameValid {
                                Text("Display name must not be blank")
                                    .font(Font.system(size: 13))
                                    .foregroundColor(Color.red)
                            }

                            TitleTextField("Password")
                                .padding(.top, 10)
                            
                            PasswordSecureField(password: $passWord)
                                .frame(height: 50)
                                .textFieldStyle(MyTextFieldStyle())
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.gray, lineWidth: 1))
                                .padding([.leading , .trailing], 1)
                                .padding(.bottom, 10)
                            TitleTextField("Confirm Password")
                            
                            PasswordSecureField(password: $passWordConfirm)
                                .frame(height: 50)
                                .textFieldStyle(MyTextFieldStyle())
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.gray, lineWidth: 1))
                                .padding([.leading , .trailing], 1)
                                .padding(.bottom, 10)
                        }
                        
                        Button(action: register) {
                            Text("Create an account")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity , minHeight: 50, idealHeight: 50)
                                .background(Color("Blue-2"))
                        }
                        .cornerRadius(10)
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                    }
                })
            }
        }
        .navigationBarItems(leading:
                                Image("ic_back_navigation")
                                .scaledToFit()
                                .foregroundColor(Color.blue)
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    self.isPresentModel = false
                                })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Register ClearKeep Account", displayMode: .inline)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.endEditing()
                })
        .padding()
        .keyboardManagment()
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
        self.isEmailValid = self.email.textFieldValidatorEmail()
        self.isDisplayNameValid = !self.userName.trimmingCharacters(in: .whitespaces).isEmpty
        
        if !self.isEmailValid || !self.isDisplayNameValid {
            return
        } else if self.passWord.isEmpty {
            self.messageAlert = "Password must not be blank"
            self.titleAlert = "Register Error"
            self.isShowAlert = true
            return
        } else if self.passWord.count < 6 {
            self.messageAlert = "Password must have at least 6 characters"
            self.titleAlert = "Register Error"
            self.isShowAlert = true
            return
        } else if self.passWord != self.passWordConfirm {
            self.messageAlert = "Password and Confirm password do not match. Please try again!"
            self.titleAlert = "Register Error"
            self.isShowAlert = true
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


struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Button")
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity , minHeight: 40, idealHeight: 0)
                .background(Color.blue)
        }
        .cornerRadius(10)
        .padding()
    }
    
}
