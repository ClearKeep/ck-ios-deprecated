//
//  SearchPeopleViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/18/20.
//

import Foundation
class SearchPeopleViewModel : ObservableObject, Identifiable {
    
    @Published var users: [People] = []
    @Published var hudVisible = false
    
    init() {
    }

    func searchUser(_ keySearch: String){
        self.hudVisible = true
        Backend.shared.searchUser(keySearch.trimmingCharacters(in: .whitespaces).lowercased()) { (result, error) in
            self.hudVisible = false
            if let result = result {
                DispatchQueue.main.async {
                    self.users.removeAll()
                    result.lstUser.forEach { (user) in
                        self.users.append(People(id: user.id, userName: user.displayName))
                    }
                }

            }
        }
    }

}
