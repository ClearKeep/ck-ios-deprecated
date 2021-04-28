//
//  PeopleViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/17/20.
//

import Foundation
import Combine
import SwiftUI

class PeopleViewModel : ObservableObject, Identifiable {
    
    @Published var users : [People] = []
    @Published var hudVisible : Bool = false
    
    func getListUser(){
        self.hudVisible = true
        Backend.shared.getListUser { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users.removeAll()
                    result.lstUser.forEach { (user) in
                        self.users.append(People(id: user.id, userName: user.displayName, userStatus: .Online))
                    }
                    self.users = self.users.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
    
    func searchUser(_ keySearch: String){
        self.hudVisible = true
        Backend.shared.searchUser(keySearch.trimmingCharacters(in: .whitespaces).lowercased()) { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users.removeAll()
                    result.lstUser.forEach { (user) in
                        self.users.append(People(id: user.id, userName: user.displayName, userStatus: .Online))
                    }
                    self.users = self.users.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
}
