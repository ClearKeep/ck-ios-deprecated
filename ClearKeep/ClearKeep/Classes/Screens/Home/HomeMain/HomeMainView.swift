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
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSheet = false

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
                                JoinServerView(action: { text in
                                    guard let text = text as? String else {return}
                                    showingSheet.toggle()
                                })
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
        .inCallModifier(callViewModel: callViewModel, isInCall: $isInCall)
        .messagerBannerModifier(data: $messageData, show: $isShowingBanner)
        .onAppear(){
            do {
                let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
                viewModel.getUserInDatabase(clientID: userLogin.id)
            } catch {
                print("get user login error")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .compatibleFullScreen(isPresented: $showingSheet) {
            LoginView(dismissAlert: $showingSheet, joinServer: true)
        }

    }
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
            .environmentObject(ViewRouter())
    }
}
