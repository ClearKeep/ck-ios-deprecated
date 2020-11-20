//
//  TabViewContainer.swift
//  ClearKeep
//
//  Created by Seoul on 11/16/20.
//

import SwiftUI

struct TabViewContainer: View {
    var body: some View {
        TabView {
            HistoryChatView()
                .tabItem {
                    VStack {
                        Image("ic_history")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                        Text("History")
                    }
                }
            
            PeopleView()
                .tabItem {
                    VStack {
                        Image("ic_contact")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Contact")
                    }
                }
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image("ic_profile")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Profile")
                    }
                }
        }
    }
}

struct TabViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        TabViewContainer()
    }
}
