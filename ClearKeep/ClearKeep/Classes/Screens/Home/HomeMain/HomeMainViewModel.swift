//
//  HomeMainViewModel.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 6/2/21.
//

import SwiftUI

class HomeMainViewModel: ObservableObject {
    
    @Published var menuItems: LeftMenuStatus = LeftMenuStatus(items: [])
    @Published var selectedServer: Int = Multiserver.instance.currentIndex
    
    init() {
        var items = [LeftMenuItemStatus]()
        getUsers().forEach { (user) in
            let item = LeftMenuItemStatus(serverID: user.id, imageName: "ic_app_new", hasNewMessage: false, onSelectCompletion: {
                
                do {
                    SharedDataAppGroup.sharedUserDefaults?.setValue(user.id, forKey: Constants.keySaveUserID)
                    try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
                    
                    if let index = Multiserver.instance.domains.firstIndex(where: { return $0.workspace_domain == user.workspace_domain.workspace_domain}) {
                        Multiserver.instance.currentIndex = index
                        
                        let refreshTokens = UserDefaultsUsers().refreshTokens
                        UserDefaults.standard.setValue(refreshTokens[index], forKey: Constants.keySaveRefreshToken)
                        
                        self.getUserInDatabase(clientID: user.id)
                    }
                    
                    self.selectedServer = Multiserver.instance.currentIndex

                } catch {
                    
                }
            })
            items.append(item)
        }
        menuItems = LeftMenuStatus(items: items)
    }
    
    func getUserInDatabase(clientID: String){
        if let dbConnection = CKDatabaseManager.shared.database?.newConnection(){
            dbConnection.readWrite({ (transaction) in
                let accounts = CKAccount.allAccounts(withUsername: clientID,
                                                     transaction: transaction)
                if let account = accounts.first {
                    
                    do {
                        let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                        databaseConnection: dbConnection)
                        CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                    } catch {
                        
                    }
                    CKSignalCoordinate.shared.myAccount = account
                }
            })
        }
    }
    
    private func getUsers() -> [User] {
        let users = UserDefaultsUsers().users
        return users
    }
}
