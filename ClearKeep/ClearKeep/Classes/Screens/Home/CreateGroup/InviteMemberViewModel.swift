//
//  InviteMemberViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

class InviteMemberViewModel: ObservableObject, Identifiable {
    
    @Published var users : [People] = []
    @Published var hudVisible : Bool = false
    
    func getListUser(){
        self.hudVisible = true
        Multiserver.instance.currentServer.getListUser { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
    
    func searchUser(_ keySearch: String){
        self.hudVisible = true
        Multiserver.instance.currentServer.searchUser(keySearch.trimmingCharacters(in: .whitespaces).lowercased()) { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
}
