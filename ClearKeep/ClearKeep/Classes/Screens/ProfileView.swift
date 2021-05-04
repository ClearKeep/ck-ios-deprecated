//
//  ProfileView.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/15/20.
//

import SwiftUI
import GoogleSignIn

struct ProfileView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    
    @State var id: String = ""
    @State var email: String = ""
    @State var userName: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var isDisable: Bool = true
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State private var titleAlert = ""

    @State var emailDisable = false
    @State var userNameDisable = false
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(Circle().stroke(Color.gray , lineWidth: 2))
                .padding(.bottom, 20)
            
            TextFieldProfile("UserName", header: "Username", text: $userName, disable: $userNameDisable) { (_) in }
            
            TextFieldProfile("Email", header: "Email", text: $email, disable: $emailDisable) { (_) in }
            
        }
        .padding()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(self.titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("OK")))
        })
        .onAppear(){
            Backend.shared.getMyProfile { (result, error) in
                if let result = result {
                    self.id = result.id
                    self.email = result.email.lowercased()
                    self.userName = result.displayName
                    self.firstName = result.firstName
                    self.lastName = result.lastName
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
