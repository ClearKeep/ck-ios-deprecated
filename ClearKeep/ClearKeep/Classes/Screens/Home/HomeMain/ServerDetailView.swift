//
//  ServerDetailView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/28/21.
//

import SwiftUI
import GoogleSignIn

struct ServerDetailView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var hudVisible = false
    @State private var showActionSheet = false
    @State private var currentUserName: String = ""
    @State private var currentWorkspaceDomain: String = ""
    
    @Binding var showDetail: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading
                )
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Spacer()
                    .frame(width: Constants.Size.leftBannerWidth + 16)
                
                VStack {
                    Spacer()
                        .frame(height: 0)
                    
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(spacing: 20) {
                            VStack(spacing: -20) {
                                HStack {
                                    Spacer()
                                    Button {
                                        showDetail = false
                                    } label: {
                                        Image("ic_close")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24, alignment: .bottom)
                                            .foregroundColor(AppTheme.colors.gray1.color)
                                            .padding(.top, 44)
                                    }
                                }
                                
                                userInfoStatus()
                            }
                            
                            Divider()
                            currentServerInfoSection()
                            Spacer()
                            generalInfoSection()

                        }
                    })
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(28, corners: [.topLeft, .bottomLeft])
                    
                    Spacer()
                        .frame(height: 0)
                }
            }
        }
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .onAppear(){
            let userLogin = Backend.shared.getUserLogin()
            if let userName = userLogin?.displayName {
                self.currentUserName = userName
            }
        }
        .alert(isPresented: $showActionSheet, content: {
            Alert(title: Text("Warning"),
                  message: Text("Are you sure you want to sign out from server?"),
                  primaryButton: .default(Text("Cancel"), action: {
                    
                  }),
                  secondaryButton: .default(Text("Sign out"), action: {
                    logout()
                  }))
        })
    }

    private func settingItemView(imageName: String, title: String, foregroundColor: Color = AppTheme.colors.gray1.color) -> some View {
        HStack {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(foregroundColor)
            
            Text(title)
                .font(AppTheme.fonts.linkSmall.font)
                .foregroundColor(foregroundColor)
            Spacer()
        }
    }
    
    private func userInfoStatus() -> some View {
        HStack(spacing: 10) {
            ChannelUserAvatar(avatarSize: 56, statusSize: 8, text: currentUserName.capitalized, image: nil, status: .active, gradientBackgroundType: .primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                Text(currentUserName.capitalized)
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.primary.color)
                    .lineLimit(2)
                
                Button(action: {}, label: {
                    HStack {
                        Text("Online")
                            .font(AppTheme.fonts.textSmall.font)
                            .foregroundColor(AppTheme.colors.success.color)
                        
                        Image("Chev-down")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(AppTheme.colors.gray1.color)
                            .frame(width: 12, height: 12, alignment: .center)
                        Spacer()
                    }
                })
                
                HStack(alignment: .center, spacing: 5) {
                    Text("\(currentWorkspaceDomain)")
                        .font(AppTheme.fonts.textXSmall.font)
                        .foregroundColor(AppTheme.colors.gray3.color)
                        .lineLimit(1)
                    Spacer()
                    Button(action: copy) {
                        Image("copy")
                            .resizable()
                            .frame(width: 24, height: 24, alignment: .center)
                            
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    private func currentServerInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink(destination: ProfileView()) {
                settingItemView(imageName: "user", title: "Profile")
            }

            NavigationLink(destination: Text("Server")) {
                settingItemView(imageName: "Adjustment", title: "Server")
            }
            .disabled(true)
            
            NavigationLink(destination: Text("Notification")) {
                settingItemView(imageName: "Notification", title: "Notification")
            }.disabled(true)
            
            NavigationLink(destination: Text("Invite")) {
                settingItemView(imageName: "user-plus", title: "Invite")
            }
            .disabled(true)
            
            NavigationLink(destination: Text("Banned")) {
                settingItemView(imageName: "user-off", title: "Blocked")
            }
            .disabled(true)
        }
    }
    
    private func generalInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: { self.confirmLogout() }) {
                settingItemView(imageName: "Logout", title: "Logout", foregroundColor: AppTheme.colors.error.color)
            }
        }
    }
    
    private func confirmLogout() {
        showActionSheet = true
    }
    
    private var confirmationSheet: ActionSheet {
        ActionSheet(
            title: Text("Logout Account"),
            message: Text("Are you sure?"),
            buttons: [
                .cancel {},
                .destructive(Text("Logout")) {
                    self.logout()
                }
            ]
        )
    }
    
    private func logout() {
        hudVisible = true
        
        Backend.shared.logout { (result) in
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hudVisible = false
            // clear data user default
            UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
            SharedDataAppGroup.sharedUserDefaults?.removeObject(forKey: Constants.keySaveUserID)
            
            // clear data user in database
            guard let connectionDb = CKDatabaseManager.shared.database?.newConnection() else { return }
            connectionDb.readWrite { (transaction) in
                CKAccount.removeAllAccounts(in: transaction)
            }
            if let myAccount = CKSignalCoordinate.shared.myAccount {
                Backend.shared.signalUnsubcrible(clientId: myAccount.username)
                Backend.shared.notificationUnSubscrible(clientId: myAccount.username)
            }
            CKSignalCoordinate.shared.myAccount = nil
            RealmManager.shared.removeAll()
            self.viewRouter.current = .login
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
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
        case .facebook:
            SocialLogin.shared.signOutFacebookAccount()
        }
    }
    
    private func copy() {
        UIPasteboard.general.string = currentWorkspaceDomain
    }

}

struct ServerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServerDetailView(showDetail: .constant(true))
    }
}
