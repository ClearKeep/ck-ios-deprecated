//
//  CKExtensions.swift
//  ClearKeep
//
//  Created by Seoul on 11/13/20.
//

import Foundation

class CKExtensions {
    static func getUserToken() -> String{
        do {
            let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
            return userLogin.token
        } catch {
            return ""
        }
    }
    
//    static var getAllGroup: [GroupModel] {
//          let defaultObject = GroupModel(id: 0, groupID: "", groupName: "", groupAvatar: "", groupType: "", createdByClientID: "", createdAt: 1, updatedByClientID: "", lstClientID: [""], updatedAt: 1)
//          if let objects = UserDefaults.standard.value(forKey: "user_groups") as? Data {
//             let decoder = JSONDecoder()
//             if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [GroupModel] {
//                return objectsDecoded
//             } else {
//                return [defaultObject]
//             }
//          } else {
//             return [defaultObject]
//          }
//       }

     static func saveAllGroup(allGroup: [GroupModel]) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(allGroup){
             UserDefaults.standard.set(encoded, forKey: "user_groups")
          }
     }
    
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
