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
    @ObservedObject var callViewModel: CallViewModel = CallViewModel()
    
    // MARK: - State
    @State private var isShowingBanner = false
    @State private var messageData: MessagerBannerModifier.MessageData = MessagerBannerModifier.MessageData()
    @State private var isShowingServerDetailView = false
    @State private var isInCall = false
    
    // MARK: - Setup
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                        .padding(.top, globalSafeAreaInsets().top)
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
            .if(isInCall, transform: { view in
                view.padding(.top, 50).edgesIgnoringSafeArea(.top)
            })
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
                callViewModel.backHandler = {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
                viewControllerHolder?.present(style: .overFullScreen, builder: {
                    CallView(viewModel: callViewModel)
                }, completion: {
                    isInCall = true
                })
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.endCall)) { (obj) in
                isInCall = false
                viewControllerHolder?.dismiss(animated: true, completion: nil)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            if isInCall {
                InCallView(senderName: callViewModel.getUserName(), callTime: callViewModel.timeCall).onTapGesture {
                    callViewModel.backHandler = {
                        viewControllerHolder?.dismiss(animated: true, completion: nil)
                    }
                    viewControllerHolder?.present(style: .overFullScreen, builder: {
                        CallView(viewModel: callViewModel)
                    })
                }
            }
        }
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


struct InCallView: View {
    var senderName: String
    var avatarIcon: Image?
    var callTime: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            ChannelUserAvatar(avatarSize: 34, text: senderName, image: avatarIcon, status: .none, gradientBackgroundType: .primary)
                .padding(.trailing, 16)
                .padding(.leading, 24)
            VStack (alignment: .leading) {
                Spacer()
                Text(senderName)
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.gray5.color)
                    .lineLimit(1)
                Text("Tap here to return to call screen")
                    .font(AppTheme.fonts.textXSmall.font)
                    .foregroundColor(AppTheme.colors.background.color)
                    .lineLimit(1)
            }
            Spacer()
            Text(callTime)
                .font(AppTheme.fonts.linkXSmall.font)
                .foregroundColor(AppTheme.colors.offWhite.color)
                .lineLimit(1)
                .padding(.trailing, 24)
        }
        .padding(.bottom, 16)
        .frame(height: globalSafeAreaInsets().top + 50)
        .background(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]).fill(AppTheme.colors.success.color))
        .edgesIgnoringSafeArea(.all)
    }
}
