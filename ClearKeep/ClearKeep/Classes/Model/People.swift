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
}

class MemberSelected: ObservableObject{
    @Published var members : [People] = []
}
