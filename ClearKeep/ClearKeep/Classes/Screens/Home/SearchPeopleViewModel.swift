//
//  SearchPeopleViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/18/20.
//

import Foundation
class SearchPeopleViewModel : ObservableObject, Identifiable {
    
    @Published var users: [People] = []
    
    init() {
    }

    func searchUser(_ keySearch: String){
        Backend.shared.searchUser(keySearch.lowercased()) { (result, error) in
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
