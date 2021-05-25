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
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    
    @State var hudVisible = false
    @State private var showActionSheet = false
    
    @Binding var isShowingServerDetailView: Bool
    @Binding var currentUserName: String
    
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
                    .frame(width: 108)
                
                VStack {
                    Spacer()
                        .frame(height: 0)
                    
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(spacing: 20) {
                            VStack(spacing: -20) {
                                HStack {
                                    Spacer()
                                    Button {
                                        self.isShowingServerDetailView.toggle()
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
                            Divider()
                            generalInfoSection()
                            Spacer()
                            Text(self.getVersionApp())
                                .fontWeight(.light)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
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
        .actionSheet(isPresented: $showActionSheet) {
            self.confirmationSheet
        }
        
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
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    private func currentServerInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("CK Develop")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.black.color)
                Spacer()
            }
            
            NavigationLink(destination: Text("Server Settings")) {
                settingItemView(imageName: "Adjustment", title: "Server Settings")
            }
            .disabled(true)
            
            NavigationLink(destination: Text("Invite other")) {
                settingItemView(imageName: "user-plus", title: "Invite other")
            }
            .disabled(true)
            
            NavigationLink(destination: Text("Banned users")) {
                settingItemView(imageName: "user-off", title: "Banned users")
            }
            .disabled(true)
            
            Button(action: {}) {
                settingItemView(imageName: "Logout", title: "Leave CK Development", foregroundColor: AppTheme.colors.error.color)
            }
            .disabled(true)
        }
    }
    
    private func generalInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("General")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.black.color)
                Spacer()
            }
            
            NavigationLink(destination: ProfileView()) {
                settingItemView(imageName: "user", title: "Account Settings")
            }
            
            NavigationLink(destination: Text("Application Settings")) {
                settingItemView(imageName: "Gear", title: "Application Settings")
            }
            .disabled(true)
            
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
            UserDefaults.standard.removeObject(forKey: Constants.keySaveUserID)
            
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
            self.realmMessages.removeAll()
            self.groupRealms.removeAll()
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
}

extension ServerDetailView {
    func getVersionApp() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildVerSion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let nameEnv = AppConfig.buildEnvironment.nameEnvironment
        let version = "Version \(appVersion) \n Build Version: \(buildVerSion) \n Environment: \(nameEnv)"
        return version
    }
}


struct ServerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServerDetailView(isShowingServerDetailView: .constant(true), currentUserName: .constant("User"))
    }
}
