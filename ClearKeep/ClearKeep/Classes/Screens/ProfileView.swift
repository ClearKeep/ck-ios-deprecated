//
//  ProfileView.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/15/20.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var showActionSheet = false
    
    @State var id: String = ""
    @State var email: String = ""
    @State var userName: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var isDisable: Bool = true


    var body: some View {
        VStack {
            Image(systemName: "car.fill")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(Circle().stroke(Color.gray , lineWidth: 2))
                .padding(.bottom, 20)
            TextFieldProfile(key: "Email", value: $email, disable: $isDisable)
            TextFieldProfile(key: "UserName", value: $userName, disable: $isDisable)
            TextFieldProfile(key: "FirstName", value: $firstName, disable: $isDisable)
            TextFieldProfile(key: "LastName", value: $lastName, disable: $isDisable)
        }
        .padding()
        .onAppear(){
            Backend.shared.getMyProfile { (result, error) in
                if let result = result {
                    self.id = result.id
                    self.email = result.email
                    self.userName = result.username
                    self.firstName = result.firstName
                    self.lastName = result.lastName
                }
            }
        }
//        .actionSheet(isPresented: $showActionSheet) {
//            self.confirmationSheet
//        }
    }

    private func logout() {
        
    }
    
    private var confirmationSheet: ActionSheet {
        ActionSheet(
            title: Text("Delete Account"),
            message: Text("Are you sure?"),
            buttons: [
                .cancel {},
                .destructive(Text("Delete")) {
                    self.delete()
                }
            ]
        )
    }

    private func confirmDelete() {
        showActionSheet = true
    }

    private func delete() {
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
