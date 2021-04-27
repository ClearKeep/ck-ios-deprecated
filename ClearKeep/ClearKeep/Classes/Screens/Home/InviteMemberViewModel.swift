//
//  InviteMemberViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

class InviteMemberViewModel: ObservableObject, Identifiable {
    
    @Published var peoples : [People] = []
    @Published var hudVisible : Bool = false
    
    func getListUser(){
        DispatchQueue.main.async {
            self.hudVisible = true
        }
        Backend.shared.getListUser { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.peoples.removeAll()
                    result.lstUser.forEach { (people) in
                        self.peoples.append(People(id: people.id, userName: people.displayName, userStatus: .Online))
                    }
                    self.hudVisible = false
                }
            } else {
                DispatchQueue.main.async {
                    self.hudVisible = false
                }
            }
        }
    }
}
