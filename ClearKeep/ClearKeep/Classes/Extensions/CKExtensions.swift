//
//  CKExtensions.swift
//  ClearKeep
//
//  Created by Seoul on 11/13/20.
//

import Foundation
import KeychainAccess

class CKExtensions {
    static func getUserToken() -> String{
        do {
            let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
            return userLogin.token
        } catch {
            return ""
        }
    }
    
     func getUUID() -> String {
        let userDefaults = UserDefaults.standard
        if let uuid = userDefaults.string(forKey: Constants.userDefaultUUID) {
          return uuid
        } else {
          let keychain = Keychain(service: Constants.keyChainService)
          if let token = try? keychain.get(Constants.keyChainUUID) {
            userDefaults.setValue(token, forKey: Constants.userDefaultUUID)
            return token

          } else {
            return self.generateNewUUID()
          }
        }
      }

      func generateNewUUID() -> String {
        let userDefaults = UserDefaults.standard
        let keychain = Keychain(service: Constants.keyChainService)

        let UUID = NSUUID().uuidString
        userDefaults.setValue(UUID, forKey: Constants.userDefaultUUID)
        userDefaults.synchronize()
        keychain[Constants.keyChainUUID] = UUID
        return UUID
      }

     static func saveAllGroup(allGroup: [GroupModel]) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(allGroup){
             UserDefaults.standard.set(encoded, forKey: "user_groups")
          }
     }
    
    static func timeToDateStringHeader(timeStamp: Int64, dateFormatter: String = "EEE MM/dd/yyyy", useTodayFormat: Bool = true) -> String{
        let date = NSDate(timeIntervalSince1970: TimeInterval(timeStamp/1000))
        let formatDate = DateFormatter()
        formatDate.dateFormat = dateFormatter
        let dateString = formatDate.string(from: date as Date)

        if useTodayFormat {
            if Calendar.current.isDateInToday(date as Date) {
                return "Today"
            }
            if Calendar.current.isDateInYesterday(date as Date) {
                return "Yesterday"
            }
        }
        
        return dateString
    }
    
    static func getMessageAndSection(_ messagess: [MessageModel]) -> [SectionWithMessage]{
        let msgs = messagess.sorted { (msg1, msg2) -> Bool in
            return msg1.createdAt < msg2.createdAt
        }
        let dict = Dictionary(grouping: msgs){
            CKExtensions.timeToDateStringHeader(timeStamp: $0.createdAt, dateFormatter: "yyyy/MM/dd", useTodayFormat: false)
        }
        var lst : [SectionWithMessage] = []
        let allKeys = dict.keys.sorted { (left, right) -> Bool in
            left < right
        }
        
        for key in allKeys {
            if let item = dict[key], let firstDate = item.first?.createdAt {
                let nextTitle = CKExtensions.timeToDateStringHeader(timeStamp: firstDate)
                lst.append(SectionWithMessage(title: nextTitle, messages: item))
            }
        }

        return lst
        
    }
    
}

extension NSNotification {
    static let ReceiveMessage = NSNotification.Name.init("ReceiveMessage")
    
    static let Notification = NSNotification.Name.init("Notification")
    
    static let AppBecomeActive = NSNotification.Name.init("AppBecomeActive")
    
    static let keyBoardWillShow = NSNotification.Name.init("keyBoardWillShow")
    
    enum GoogleSignIn {
        static let FinishedWithResponse = NSNotification.Name.init("GoogleSignIn.FinishedWithResponse")
        static let FinishedWithError = NSNotification.Name.init("GoogleSignIn.FinishedWithError")
        static let DisconnectedWithResponse = NSNotification.Name.init("GoogleSignIn.DisconnectedWithResponse")
    }
    
    enum MicrosoftSignIn {
        static let FinishedWithResponse = NSNotification.Name.init("MicrosoftSignIn.FinishedWithResponse")
        static let FinishedWithError = NSNotification.Name.init("MicrosoftSignIn.FinishedWithError")
    }
    
    enum FacebookSignIn {
        static let FinishedWithResponse = NSNotification.Name.init("FacebookSignIn.FinishedWithResponse")
        static let FinishedWithError = NSNotification.Name.init("FacebookSignIn.FinishedWithError")
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

extension CGSize {
    func aspectFitScale(in container: CGSize) -> CGFloat {
        if width == 0 || height == 0 {
            return 0
        }

        if height <= container.height && width > container.width {
            return container.width / width
        }
        if height > container.height && width > container.width {
            return min(container.width / width, container.height / height)
        }
        if height > container.height && width <= container.width {
            return container.height / height
        }
        if height <= container.height && width <= container.width {
            return min(container.width / width, container.height / height)
        }
        return 1.0
    }
    
    func aspectFillScale(in container: CGSize) -> CGFloat {
        if width == 0 || height == 0 {
            return 0
        }
        
        if height <= container.height && width > container.width {
            return container.height / height
        }
        if height > container.height && width > container.width {
            return max(container.width / width, container.height / height)
        }
        if height > container.height && width <= container.width {
            return container.width / width
        }
        if height <= container.height && width <= container.width {
            return max(container.width / width, container.height / height)
        }
        return 1.0
    }
}
