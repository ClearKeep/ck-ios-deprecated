//
//  TabViewContainer.swift
//  ClearKeep
//
//  Created by Seoul on 11/16/20.
//

import SwiftUI

struct TabViewContainer: View {
    
    @ObservedObject var viewModel = MotherViewModel()

    
    var body: some View {
        TabView {
            HistoryChatView().environmentObject(RealmGroups()).environmentObject(RealmMessages())
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
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
                        Image(systemName: "person.3.fill")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Contact")
                    }
                }
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.fill")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("Profile")
                    }
                }
        }
        .onAppear(){
            do {
                let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
                viewModel.getUserInDatabase(clientID: userLogin.id)
                self.subscribleMessages()
                self.subscribleNotify()
            } catch {
                print("get user login error")
            }
        }
    }
}


extension TabViewContainer {
    private func subscribleNotify(){
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            Backend.shared.notificationSubscrible(clientId: myAccount.username)
        }
    }
    
    private func subscribleMessages(){
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            Backend.shared.signalSubscrible(clientId: myAccount.username)
        }
    }
}

struct TabViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        TabViewContainer()
    }
}
