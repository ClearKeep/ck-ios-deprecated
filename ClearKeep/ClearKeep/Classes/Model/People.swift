//
//  People.swift
//  ClearKeep
//
//  Created by Seoul on 11/17/20.
//

import SwiftUI

struct People: Identifiable , Hashable {
    var id : String
    var userName : String
    var userStatus : Status
    
    var workspace_domain: String = ""
}

enum Status : String {
    case Online
    case Offline
    case Busy
}

class MemberSelected: ObservableObject{
    @Published var members : [People] = []
}
