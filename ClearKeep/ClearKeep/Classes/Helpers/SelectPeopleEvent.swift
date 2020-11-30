//
//  SelectPeopleEvent.swift
//  ClearKeep
//
//  Created by Seoul on 11/25/20.
//

import Foundation

class SelectPeopleEvent: EventType{
    let members: [People]
    
    init(members: [People]) {
        self.members = members
    }
}
