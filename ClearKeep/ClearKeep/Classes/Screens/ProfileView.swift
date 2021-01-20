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
    @State var hudVisible = false

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .overlay(Circle().stroke(Color.gray , lineWidth: 2))
                .padding(.bottom, 20)
            TextFieldProfile(key: "Email", value: $email, disable: $isDisable)
            TextFieldProfile(key: "UserName", value: $userName, disable: $isDisable)
            // Logout button
            Button(action: logout) {
                ButtonContent("LOGOUT")
                    .padding(.trailing, 25)
            }
        }
        .padding()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
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
        hudVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hudVisible = false
            // clear data user default
            UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
            // clear data user in database
            guard let connectionDb = CKDatabaseManager.shared.database?.newConnection() else { return }
            connectionDb.readWrite { (transaction) in
                CKAccount.removeAllAccounts(in: transaction)
            }
            CKSignalCoordinate.shared.myAccount = nil
            self.viewRouter.current = .login
        }
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
