//
//  Binding+Extension.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/5/21.
//

import SwiftUI

extension Binding where Value == Bool {
    
    public func inversed() -> Binding<Bool> {
        return Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
