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
    @State private var showActionSheet = false
    
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
            Button(action: confirmDelete) {
                ButtonContent("LOGOUT")
                    .padding(.trailing, 25)
            }
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
                    self.email = result.email
                    self.userName = result.displayName
                    self.firstName = result.firstName
                    self.lastName = result.lastName
                }
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            self.confirmationSheet
        }
    }

    private func logout() {
        hudVisible = true
        Backend.shared.logout { (result) in
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hudVisible = false
            // clear data user default
            UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
            UserDefaults.standard.removeObject(forKey: Constants.keySaveUserID)
            
            // clear data user in database
            guard let connectionDb = CKDatabaseManager.shared.database?.newConnection() else { return }
            connectionDb.readWrite { (transaction) in
                CKAccount.removeAllAccounts(in: transaction)
            }
            CKSignalCoordinate.shared.myAccount = nil
            self.realmMessages.removeAll()
            self.groupRealms.removeAll()
            self.viewRouter.current = .login

        }
        
        // Clean signin state
        let currentSignInType = SocialLogin.shared.currentSignInType
        SocialLogin.shared.saveSignInType(nil)
        
        switch currentSignInType {
        case .email: break
        case .google:
            if (GIDSignIn.sharedInstance()?.hasPreviousSignIn() ?? false) {
                GIDSignIn.sharedInstance().signOut()
            }
        case .microsoft:
            SocialLogin.shared.signOutO365()
        }
    }
    
    private var confirmationSheet: ActionSheet {
        ActionSheet(
            title: Text("Logout Account"),
            message: Text("Are you sure?"),
            buttons: [
                .cancel {},
                .destructive(Text("Logout")) {
                    self.delete()
                }
            ]
        )
    }

    private func confirmDelete() {
        showActionSheet = true
    }

    private func delete() {
        logout()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
