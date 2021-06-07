//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Nguyễn Nam on 6/4/21.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var database: YapDatabase?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        getSharedDatabase()
        if let bestAttemptContent = bestAttemptContent {
            if let publication = bestAttemptContent.userInfo["publication"],
               let jsonString = publication as? String,
               let jsonData = jsonString.data(using: .utf8) {
                do {
                    let publication = try JSONDecoder().decode(ChatService.PublicationNotification.self, from: jsonData)
                    if publication.groupType == "peer" {
                        ChatService.shared.decryptMessageFromPeer(publication, completion: { message in
                            bestAttemptContent.body = message
                            contentHandler(bestAttemptContent)
                        })
                    } else {
                        ChatService.shared.decryptMessageFromGroup(publication, completion: { message in
                            bestAttemptContent.body = message
                            contentHandler(bestAttemptContent)
                        })
                    }
                } catch {
                    bestAttemptContent.body = "\(#function) 1"
                    contentHandler(bestAttemptContent)
                }
            } else {
                bestAttemptContent.body = "\(#function) 2"
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            if let publication = bestAttemptContent.userInfo["publication"],
               let jsonString = publication as? String,
               let jsonData = jsonString.data(using: .utf8) {
                do {
                    let publication = try JSONDecoder().decode(ChatService.PublicationNotification.self, from: jsonData)
                    if publication.groupType == "peer" {
                        ChatService.shared.decryptMessageFromPeer(publication, completion: { message in
                            bestAttemptContent.body = message
                            contentHandler(bestAttemptContent)
                        })
                    } else {
                        ChatService.shared.decryptMessageFromGroup(publication, completion: { message in
                            bestAttemptContent.body = message
                            contentHandler(bestAttemptContent)
                        })
                    }
                } catch {
                    bestAttemptContent.body = "\(#function) 1"
                    contentHandler(bestAttemptContent)
                }
            } else {
                bestAttemptContent.body = "\(#function) 2"
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    func getSharedDatabase() {
            let options = YapDatabaseOptions()
            options.corruptAction = .fail
        options.cipherCompatability = .version3;
                if CKDatabaseManager.shared.database == nil {
                    CKDatabaseManager.shared.setupDatabase(withName: "CKDatabase.sqlite", directory: SharedDataAppGroup.sharedDirectoryPath())
                }
                
                if let userName = SharedDataAppGroup.sharedUserDefaults?.string(forKey: Constants.keySaveUserID),
                   let connectionDb = CKDatabaseManager.shared.database?.newConnection() {
                    connectionDb.readWrite({ (transaction) in
                    let accounts = CKAccount.allAccounts(withUsername: userName,
                                                         transaction: transaction)
                    if let account = accounts.first {  
                        do {
                            let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                            databaseConnection: connectionDb)
                            CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                        } catch {
                            print("error: \(error.localizedDescription)")
                        }
                        CKSignalCoordinate.shared.myAccount = account
                    }
                })
            }
    }
}
