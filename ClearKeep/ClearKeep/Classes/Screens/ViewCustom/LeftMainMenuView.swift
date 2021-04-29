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
            .frame(width: 84)
            .cornerRadius(28, corners: .topRight)
            .edgesIgnoringSafeArea(.bottom)
            
            
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 16)
                
                ForEach(leftMenuStatus.items, id:\.serverID) { item in
                    Button(action: {
                        self.leftMenuStatus.selectedServerID = item.serverID
                        item.onSelectCompletion?()
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
                        .frame(width: 24, height: 24, alignment: .center)
                        .padding(.all, 2)
                        .foregroundColor(.white)
                        .gradientHeader()
                        .clipShape(Circle())
                        .padding(.all, 8)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(self.leftMenuStatus.selectedServerID == LeftMainMenuView.joinServerItemID ? AppTheme.colors.primary.color : Color.clear, lineWidth: 1.5)
                        )
                })
                
                Spacer()
                 
                AppTheme.colors.offWhite.color
                    .frame(height: 0.5)
                
                Button(action: {
                    self.leftMenuStatus.selectedServerID = LeftMainMenuView.manageContactItemID
                    self.manageContactHandler()
                }, label: {
                    Image("user")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(AppTheme.colors.primary.color)
                        .clipShape(Circle())
                })
                .padding(.bottom, 40)
            }
            .frame(width: 84, alignment: .leading)
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
