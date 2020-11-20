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
    
    @Published var users: [People] = []
    
    init() {
    }
    
    func getUser(){
        Backend.shared.getListUser { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.users.removeAll()
                    result.lstUser.forEach { (user) in
                        self.users.append(People(id: user.id, userName: user.username))
                    }
                }
                
            }
        }
    }
    
}
