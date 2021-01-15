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
    @State var firstName: String = ""
    @State var lastName: String = ""
    
    var body: some View {
        VStack {
            TitleLabel("ClearKeep")
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
    }
}

extension RegisterView {
    private func register(){
        var request = Auth_RegisterReq()
        request.username = self.userName
        request.password = self.passWord
        request.email = self.email
        request.firstName = self.firstName
        request.lastName = self.lastName
        
        Backend.shared.register(request) { (result) in
            if result {
                self.viewRouter.current = .login
            } else {
                print("Register account fail")
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
