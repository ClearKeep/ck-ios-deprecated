//
//  RealmMessage.swift
//  ClearKeep
//
//  Created by Seoul on 11/30/20.
//

import Foundation
import RealmSwift

class RealmMessage: Object {
    @objc dynamic var id: String = String()
    @objc dynamic var groupID: String = String()
    @objc dynamic var groupType: String = String()
    @objc dynamic var fromClientID: String = String()
    @objc dynamic var clientID: String = String()
    @objc dynamic var message = Data()
    @objc dynamic var createdAt: Int64 = 0
    @objc dynamic var updatedAt: Int64 = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
