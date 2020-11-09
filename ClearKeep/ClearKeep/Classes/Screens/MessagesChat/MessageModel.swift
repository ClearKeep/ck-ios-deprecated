//
//  MessageModel.swift
//  ClearKeep
//
//  Created by Luan Nguyen on 10/30/20.
//

import Foundation

struct MessageModel: Identifiable {
    let id: Int8 = 11
    var newID = UUID().uuidString
    var from: String
    var data: Data
}
