//
//  LeftMainMenuView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

class LeftMenuItemStatus: Identifiable {
    var id: UUID = UUID()
    var imageName: String
    var hasNewMessage: Bool
    var onSelectCompletion: VoidCompletion?
    
    init(imageName: String, hasNewMessage: Bool = false, onSelectCompletion: VoidCompletion?) {
        self.imageName = imageName
        self.hasNewMessage = hasNewMessage
    }
}

class LeftMenuStatus: ObservableObject {
    @Published var selectedItemId: UUID = UUID()
    @Published var items: [LeftMenuItemStatus] = []
    
    init(items: [LeftMenuItemStatus]) {
        self.items = items
        if let defaultSelectedId = items.first?.id {
            self.selectedItemId = defaultSelectedId
        }
    }
}

struct LeftMainMenuView: View {
    @ObservedObject var leftMenuStatus: LeftMenuStatus
    
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
                    .frame(height: 20)
                
                ForEach(leftMenuStatus.items) { item in
                    Button(action: {
                        self.leftMenuStatus.selectedItemId = item.id
                        item.onSelectCompletion?()
                    }, label: {
                        MainMenuItemView(isSelected: item.id == leftMenuStatus.selectedItemId, hasNewMessage: item.hasNewMessage)
                    })
                }
                
                Spacer()
                 
                AppTheme.colors.offWhite.color
                    .frame(height: 0.5)
                
                Button(action: {
                    
                }, label: {
                    Image("user")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(AppTheme.colors.primary.color)
                        .clipShape(Circle())
                })
                .padding(.bottom, 16)
            }
            .frame(width: 84, alignment: .leading)
            .cornerRadius(24)
        }
    }
}

struct LeftMainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LeftMainMenuView(leftMenuStatus: LeftMenuStatus(items: [
                                                                LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: nil),
                LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: nil),
                LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: nil),
                LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: nil)]))
            Spacer()
        }
    }
}
