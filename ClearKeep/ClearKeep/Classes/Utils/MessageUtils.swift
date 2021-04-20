//
//  MessageUtils.swift
//  ClearKeep
//
//  Created by Seoul on 4/19/21.
//

import Foundation
class MessageUtils {
    
    static func separateMessageList(messages: [MessageModel]) -> Array<[MessageModel]>{
        var result: Array<Array<MessageModel>> = []
        var cache: Array<MessageModel> = []
        var currentSenderId = ""
        
        messages.forEach { (message) in
            if (currentSenderId.isEmpty || currentSenderId != message.fromClientID) {
                currentSenderId = message.fromClientID
                if (!cache.isEmpty) {
                    result.append(cache)
                }
                cache = []
            }
            cache.append(message)
        }
        result.append(cache)
        
        return result
    }
    
    static func getListRectCorner(messages: [MessageModel]) -> [MessageDisplayInfo]{
        let separateMessageList = self.separateMessageList(messages: messages)
        var listMessageDisplay : [MessageDisplayInfo] = []
        separateMessageList.forEach { (subList) in
            let groupedSize = subList.count
            let list = subList.enumerated().map { (index , message) in
                MessageDisplayInfo(message: message, rectCorner: message.myMsg ? self.getOwnerRectCorner(index: index, size: groupedSize) : self.getOtherRectCorner(index: index, size: groupedSize), showAvatarAndUserName: self.isShowAvatarAndUserName(index: index, size: groupedSize))
            }
            listMessageDisplay.append(contentsOf: list)
        }
        return listMessageDisplay
    }
    
    static func isShowAvatarAndUserName(index: Int, size: Int) -> Bool {
        return size == 1 ? true : index == 0 ? true : false
    }
    
    static func getOwnerRectCorner(index: Int, size: Int) -> UIRectCorner {
        if size == 1 {
            return [.topLeft , .topRight , .bottomLeft]
        } else {
            switch index {
            case 0:
                return [.topLeft , .topRight , .bottomLeft]
            case size - 1:
                return [.topLeft , .bottomRight , .bottomLeft]
            default:
                return [.topLeft , .bottomLeft]
            }
        }
    }
    
    static func getOtherRectCorner(index: Int, size: Int) -> UIRectCorner {
        if size == 1 {
            return [.topLeft , .topRight , .bottomRight]
        } else {
            switch index {
            case 0:
                return [.topLeft , .topRight , .bottomRight]
            case size - 1:
                return [.topRight , .bottomLeft , .bottomRight]
            default:
                return [.topRight , .bottomRight]
            }
        }
    }
    
    
}
