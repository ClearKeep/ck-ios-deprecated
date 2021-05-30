//
//  MotherViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/20/20.
//

import SwiftUI

class MotherViewModel: ObservableObject, Identifiable {
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
