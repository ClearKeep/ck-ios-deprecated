//
//  HomeMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

struct HomeMainView: View {
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(alignment: .top) {
                    LeftMainMenuView(leftMenuStatus: menuItems)
                    mainContainerView()
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
    var menuItems: LeftMenuStatus {
        return LeftMenuStatus(items: [
            LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: nil),
            LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: nil),
            LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: nil),
            LeftMenuItemStatus(imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: nil)])
    }
    
    func mainContainerView() -> some View {
        ServerMainView()
    }
}

struct HomeMainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainView()
    }
}
