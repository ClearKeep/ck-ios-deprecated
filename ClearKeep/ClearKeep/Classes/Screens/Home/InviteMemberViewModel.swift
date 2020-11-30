//
//  InviteMemberViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

class InviteMemberViewModel: ObservableObject, Identifiable {
    
    @Published var peoples : [People] = []
    
    func getListUser(){
        Backend.shared.getListUser { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.peoples.removeAll()
                    result.lstUser.forEach { (people) in
                        self.peoples.append(People(id: people.id, userName: people.username))
                    }
                }
            }
        }
    }
}
