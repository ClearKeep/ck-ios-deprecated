//
//  HomeMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

enum HomeMainContentType: String {
    case currentServerInfo
    case joinNewServer
}

struct HomeMainView: View {
    
    @ObservedObject var mainViewModel: HomeMainViewModel = HomeMainViewModel()
    @State private var isShowingServerDetailView = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                GeometryReader { geometry in
                    HStack(alignment: .top) {
                        LeftMainMenuView(leftMenuStatus: mainViewModel.menuItems,
                                         joinServerHandler: {
                                            self.mainViewModel.homeMainContentType = .joinNewServer
                                         },
                                         manageContactHandler: {})
                        
                        switch self.mainViewModel.homeMainContentType {
                        case .currentServerInfo: ServerMainView(isShowingServerDetailView: $isShowingServerDetailView)
                        case .joinNewServer: JoinServerView()
                        }
                    }
                    .padding(.top, 45)
                    .plainColorBackground(color: AppTheme.colors.offWhite.color)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .blur(radius: isShowingServerDetailView ? 10 : 0.0)
                
                if isShowingServerDetailView {
                    ServerDetailView(isShowingServerDetailView: $isShowingServerDetailView)
                }
            }
        }
        .onAppear(){
            do {
                let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
                mainViewModel.getUserInDatabase(clientID: userLogin.id)
            } catch {
                print("get user login error")
            }
        }
    }
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}

class HomeMainViewModel: ObservableObject {
    
    @Published var menuItems: LeftMenuStatus = LeftMenuStatus(items: [])
    @Published var homeMainContentType: HomeMainContentType = .currentServerInfo
    
    init() {
        menuItems = LeftMenuStatus(items: [
            LeftMenuItemStatus(serverID: "ck_default_1", imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: {
                self.homeMainContentType = .currentServerInfo
            })
        ])
    }
    
    func getUserInDatabase(clientID: String){
        if let dbConnection = CKDatabaseManager.shared.database?.newConnection(){
            dbConnection.readWrite({ (transaction) in
                let accounts = CKAccount.allAccounts(withUsername: clientID,
                                                     transaction: transaction)
                if let account = accounts.first {
                    
                    do {
                        let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                        databaseConnection: dbConnection)
                        CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                    } catch {
                        
                    }
                    CKSignalCoordinate.shared.myAccount = account
                }
            })
            
        }
    }
}
