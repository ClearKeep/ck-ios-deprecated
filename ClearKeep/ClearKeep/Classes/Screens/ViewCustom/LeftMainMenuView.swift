//
//  LeftMainMenuView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

class LeftMenuItemStatus: Identifiable {
    var serverID: String
    var imageName: String
    var hasNewMessage: Bool
    var onSelectCompletion: VoidCompletion?
    
    init(serverID: String, imageName: String, hasNewMessage: Bool = false, onSelectCompletion: VoidCompletion?) {
        self.serverID = serverID
        self.imageName = imageName
        self.hasNewMessage = hasNewMessage
        self.onSelectCompletion = onSelectCompletion
    }
}

class LeftMenuStatus: ObservableObject {
    @Published var selectedServerID: String = "" {
        didSet {
            print("Selected item: " + selectedServerID)
        }
    }
    @Published var items: [LeftMenuItemStatus] = []
    
    init(items: [LeftMenuItemStatus]) {
        self.items = items
        if let defaultSelectedId = items.first?.serverID, self.selectedServerID.isEmpty {
            self.selectedServerID = defaultSelectedId
        }
    }
}

struct LeftMainMenuView: View {
    @ObservedObject var leftMenuStatus: LeftMenuStatus
    
    var joinServerHandler: VoidCompletion
    var selectedServerHandler: ObjectCompletion?

    var manageContactHandler: VoidCompletion
    
    static let joinServerItemID = "joinServerItemID#270421"
    static let manageContactItemID = "manageContactItemID#270421"
    
    var body: some View {
        ZStack {
                Group {
                    LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing)
                        
                    AppTheme.colors.offWhite.color
                        .opacity(0.72)
                }
                .frame(width: Constants.Size.leftBannerWidth)
                .cornerRadius(28, corners: .topRight)
                .edgesIgnoringSafeArea(.bottom)
                
                
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 16)
                    
                    ForEach(leftMenuStatus.items, id:\.serverID) { item in
                        Button(action: {
                            self.leftMenuStatus.selectedServerID = item.serverID
                            item.onSelectCompletion?()                            
                            self.selectedServerHandler?(item)
                        }, label: {
                            MainMenuItemView(isSelected: item.serverID == leftMenuStatus.selectedServerID, hasNewMessage: item.hasNewMessage)
                        })
                    }
                    
                    Button(action: {
                        self.leftMenuStatus.selectedServerID = LeftMainMenuView.joinServerItemID
                        self.joinServerHandler()
                    }, label: {
                        Image("Plus_white")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 28, height: 28, alignment: .center)
                            .padding(.all, 2)
                            .foregroundColor(.white)
                            .gradientHeader()
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            .padding(.all, 8)
                    })
                    
                    Spacer()
                     
                    AppTheme.colors.offWhite.color
                        .frame(height: 0.5)
                }
                .frame(width: Constants.Size.leftBannerWidth, alignment: .leading)
                .cornerRadius(24)
            
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

struct LeftMainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LeftMainMenuView(leftMenuStatus: LeftMenuStatus(items: [
                                                                LeftMenuItemStatus(serverID: "ck_default", imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: nil),
                LeftMenuItemStatus(serverID: "ck_default_2", imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: nil),
                LeftMenuItemStatus(serverID: "ck_default_3", imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: nil),
                LeftMenuItemStatus(serverID: "ck_default_4", imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: nil)]),
                             joinServerHandler: {},
                             manageContactHandler: {})
            Spacer()
        }
    }
}
