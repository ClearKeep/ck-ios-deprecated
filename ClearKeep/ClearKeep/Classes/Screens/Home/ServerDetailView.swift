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
    
    @Binding var isShowingServerDetailView: Bool
    @State var hudVisible = false
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
        
    }
    
    private func settingItemView(imageName: String, title: String, action: @escaping VoidCompletion, foregroundColor: Color = AppTheme.colors.gray1.color) -> some View {
        Button(action: action, label: {
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
        })
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
            
            settingItemView(imageName: "Adjustment", title: "Server Settings", action: {})
            
            settingItemView(imageName: "user-plus", title: "Invite other", action: {})
            
            settingItemView(imageName: "user-off", title: "Banned users", action: {})
            
            settingItemView(imageName: "Logout", title: "Leave CK Development", action: {}, foregroundColor: AppTheme.colors.error.color)
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
            
            settingItemView(imageName: "user", title: "Account Settings", action: {})
            
            settingItemView(imageName: "Gear", title: "Application Settings", action: {})
            
            settingItemView(imageName: "Logout", title: "Logout", action: {
                self.logout()
            }, foregroundColor: AppTheme.colors.error.color)
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
        case .facebook:
            SocialLogin.shared.signOutFacebookAccount()
        }
    }
}

struct ServerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServerDetailView(isShowingServerDetailView: .constant(true), currentUserName: .constant("User"))
    }
}
