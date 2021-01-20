//
//  RegisterView.swift
//  ClearKeep
//
//  Created by Seoul on 11/12/20.
//

import SwiftUI
import TTProgressHUD

struct RegisterView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email: String = ""
    @State var userName: String = ""
    @State var passWord: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @Binding var isPresentModel: Bool
    @State var hudVisible = false
    
    var body: some View {
        VStack {
            TitleLabel("Register Account")
            TextFieldContent(key: "Email", value: $email)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            TextFieldContent(key: "UserName", value: $userName)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            PasswordSecureField(password: $passWord)
//            TextFieldContent(key: "FirstName", value: $firstName)
//                .autocapitalization(.none)
//                .disableAutocorrection(true)
//            TextFieldContent(key: "LastName", value: $lastName)
//                .autocapitalization(.none)
//                .disableAutocorrection(true)
            Button(action: register) {
                ButtonContent("REGISTER")
            }
        }
        .padding()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
    }
}

extension RegisterView {
    private func register(){
        hudVisible = true
        var request = Auth_RegisterReq()
        request.username = self.userName
        request.password = self.passWord
        request.email = self.email
        request.firstName = self.firstName
        request.lastName = self.lastName
        
        Backend.shared.register(request) { (result) in
            hudVisible = false
            if result {
//                self.viewRouter.current = .login
                isPresentModel = false
            } else {
                print("Register account fail")
            }
        }
    }
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView(Con)
//    }
//}
