//
//  SecondaryIndexes.swift
//  ChatSecureCore
//
//  Created by Chris Ballinger on 11/7/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import Foundation
import YapDatabase

extension YapDatabaseSecondaryIndexOptions {
    convenience init(whitelist: [String]) {
        let set = Set(whitelist)
        let whitelist = YapWhitelistBlacklist(whitelist: set)
        self.init()
        self.allowedCollections = whitelist
    }
}

extension YapDatabaseSecondaryIndex {
    
    @objc public static var signalIndex: YapDatabaseSecondaryIndex {
        let columns: [String:YapDatabaseSecondaryIndexType] = [
            SignalIndexColumnName.session: .text,
            SignalIndexColumnName.preKeyId: .integer,
            SignalIndexColumnName.preKeyAccountKey: .text
        ]
        let setup = YapDatabaseSecondaryIndexSetup(capacity: UInt(columns.count))
        columns.forEach { (key, value) in
            setup.addColumn(key, with: value)
        }
        
        let handler = YapDatabaseSecondaryIndexHandler.withObjectBlock { (transaction, dict, collection, key, object) in
            if let session = object as? CKSignalSession {
                if session.name.count > 0 {
                    dict[SignalIndexColumnName.session] = session.sessionKey
                }
            } else if let preKey = object as? CKSignalPreKey {
                dict[SignalIndexColumnName.preKeyId] = preKey.keyId
                if preKey.accountKey.count > 0 {
                    dict[SignalIndexColumnName.preKeyAccountKey] = preKey.accountKey
                }
            }
        }
        let options = YapDatabaseSecondaryIndexOptions(whitelist: [CKSignalPreKey.collection,CKSignalSession.collection])
        let secondaryIndex = YapDatabaseSecondaryIndex(setup: setup, handler: handler, versionTag: "6", options: options)
        return secondaryIndex
    }
}

// MARK: - Constants

/// YapDatabase extension names for Secondary Indexes
@objc public class SecondaryIndexName: NSObject {
    @objc public static let messages = "CKMessagesSecondaryIndex"
    @objc public static let signal = "CKYapDatabseMessageIdSecondaryIndexExtension"
    @objc public static let roomOccupants = "SecondaryIndexName_roomOccupantIndex"
    @objc public static let buddy = "SecondaryIndexName_buddy"
    @objc public static let mediaItems = "SecondaryIndexName_mediaItems"
}

@objc public class BuddyIndexColumnName: NSObject {
    @objc public static let accountKey = "BuddyIndexColumnName_accountKey"
    @objc public static let username = "BuddyIndexColumnName_username"
}

@objc public class MessageIndexColumnName: NSObject {
    @objc public static let messageKey = "CKYapDatabaseMessageIdSecondaryIndexColumnName"
    @objc public static let remoteMessageId = "CKYapDatabaseRemoteMessageIdSecondaryIndexColumnName"
    @objc public static let threadId = "CKYapDatabaseMessageThreadIdSecondaryIndexColumnName"
    @objc public static let isMessageRead = "CKYapDatabaseUnreadMessageSecondaryIndexColumnName"
    
    
    /// XEP-0359 origin-id
    @objc public static let originId = "SecondaryIndexNameOriginId"
    /// XEP-0359 stanza-id
    @objc public static let stanzaId = "SecondaryIndexNameStanzaId"
}

@objc public class RoomOccupantIndexColumnName: NSObject {
    /// jids
    @objc public static let jid = "CKYapDatabaseRoomOccupantJidSecondaryIndexColumnName"
    @objc public static let realJID = "RoomOccupantIndexColumnName_realJID"
    @objc public static let roomUniqueId = "RoomOccupantIndexColumnName_roomUniqueId"
    @objc public static let buddyUniqueId = "RoomOccupantIndexColumnName_buddyUniqueId"
}

@objc public class SignalIndexColumnName: NSObject {
    @objc public static let session = "CKYapDatabaseSignalSessionSecondaryIndexColumnName"
    @objc public static let preKeyId = "CKYapDatabaseSignalPreKeyIdSecondaryIndexColumnName"
    @objc public static let preKeyAccountKey = "CKYapDatabaseSignalPreKeyAccountKeySecondaryIndexColumnName"
}

@objc public class MediaItemIndexColumnName: NSObject {
    @objc public static let mediaItemId = "MediaItemIndexColumnName_mediaItemId"
    @objc public static let transferProgress = "MediaItemIndexColumnName_transferProgress"
    @objc public static let isIncoming = "MediaItemIndexColumnName_isIncoming"
}
