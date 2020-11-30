//
//  CreateRoomViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import Foundation

class CreateRoomViewModel: ObservableObject, Identifiable {
    @Published var peoples : [People] = []

}
