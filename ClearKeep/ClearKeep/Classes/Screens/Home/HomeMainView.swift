//
//  HomeMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

struct HomeMainView: View {
    // MARK: - Environment
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    // MARK: - ObservedObject
    @ObservedObject var viewModel: HomeMainViewModel = HomeMainViewModel()
    @ObservedObject var serverMainViewModel: ServerMainViewModel = ServerMainViewModel()
    
    // MARK: - State
    @State private var isShowingBanner = false
    @State private var messageData: MessagerBannerModifier.MessageData = MessagerBannerModifier.MessageData()
    @State private var isShowingServerDetailView = false
    
    // MARK: - Setup
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                GeometryReader { geometry in
                    HStack(alignment: .top, spacing: 0) {
                        LeftMainMenuView(leftMenuStatus: viewModel.menuItems,
                                         joinServerHandler: {
                                            viewModel.selectedServer = "Joined server"
                                         },
                                         manageContactHandler: {})
                        VStack {
                            Spacer()
                                .frame(height: 4)
                            
                            HStack {
                                Text(viewModel.selectedServer)
                                    .font(AppTheme.fonts.displaySmallBold.font)
                                    .foregroundColor(AppTheme.colors.black.color)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        isShowingServerDetailView = true
                                    }
                                }, label: {
                                    Image("Hamburger")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24, alignment: .center)
                                        .foregroundColor(AppTheme.colors.gray1.color)
                                })
                            }
                            
                            if viewModel.selectedServer == "CK Development" {
                                ServerMainView(viewModel: serverMainViewModel, messageData: $messageData, isShowMessageBanner: $isShowingBanner)
                            } else {
                                JoinServerView()
                            }
                        }
                        .padding(.all, Constants.Device.isSmallScreenSize ? 10 : 16)
                    }
                    .padding(.top, 45)
                    .plainColorBackground(color: AppTheme.colors.offWhite.color)
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .blur(radius: isShowingServerDetailView ? 5 : 0)
                
                if isShowingServerDetailView {
                    ServerDetailView(showDetail: $isShowingServerDetailView).transition(.identity)
                }
            }
        }
        .messagerBannerModifier(data: $messageData, show: $isShowingBanner)
        .onAppear(){
            do {
                let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
                viewModel.getUserInDatabase(clientID: userLogin.id)
            } catch {
                print("get user login error")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.receiveCall)) { (obj) in
            viewControllerHolder?.present(style: .overFullScreen, builder: {
                CallView()
            })
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.endCall)) { (obj) in
            viewControllerHolder?.dismiss(animated: true, completion: nil)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
            .environmentObject(ViewRouter())
    }
}

class HomeMainViewModel: ObservableObject {
    
    @Published var menuItems: LeftMenuStatus = LeftMenuStatus(items: [])
    @Published var selectedServer: String = "CK Development"
    
    init() {
        menuItems = LeftMenuStatus(items: [
            LeftMenuItemStatus(serverID: "ck_default_1", imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: {
                self.selectedServer = "CK Development"
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
