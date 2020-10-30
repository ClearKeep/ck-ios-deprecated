//
//  MessageModel.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import Foundation

struct MessageModel: Identifiable {
    let id: Int8 = 11
    var newID = UUID().uuidString
    var from: String
    var data: Data
}
