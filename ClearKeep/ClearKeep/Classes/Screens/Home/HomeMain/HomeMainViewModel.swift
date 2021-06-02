//
//  HomeMainViewModel.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 6/2/21.
//

import SwiftUI

class HomeMainViewModel: ObservableObject {
    
    @Published var menuItems: LeftMenuStatus = LeftMenuStatus(items: [])
    @Published var selectedServer: String = "CK Development"
    
    init() {
        menuItems = LeftMenuStatus(items: [
            LeftMenuItemStatus(serverID: "ck_default_1", imageName: "ic_app_new", hasNewMessage: true, onSelectCompletion: {
                self.selectedServer = "CK Development"
            })
        ])
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
}
