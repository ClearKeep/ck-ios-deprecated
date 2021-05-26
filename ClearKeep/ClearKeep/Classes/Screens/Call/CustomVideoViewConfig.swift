//
//  CustomVideoViewConfig.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 26/05/2021.
//

import SwiftUI

class CustomVideoViewConfig: ObservableObject {
    @Published var cameraOn = true
    @Published var microEnable = true
    @Published var showOptionView = false
    
    let avatarImage: Image? = nil
    @Published var userName: String = ""
    
    var clientId: String = ""
    var groupId: Int64 = -1
    
    private var timeoutTimer: Timer?
    func triggerOptionDisplayTimeout() {
        showOptionView.toggle()
        
        if let timer = timeoutTimer {
            timer.invalidate()
            timeoutTimer = nil
        }
        
        guard showOptionView else { return }
        
        timeoutTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(showOptionViewTimeout), userInfo: nil, repeats: false)
        RunLoop.current.add(timeoutTimer!, forMode: .default)
    }
    
    @objc private func showOptionViewTimeout() {
        showOptionView = false
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    func fetchLocalUserName() {
        let fetchedUsername = RealmManager.shared.getDisplayNameSenderMessage(fromClientId: clientId, groupID: groupId)
        self.userName = fetchedUsername
    }
    
    init(clientId: String, groupId: Int64) {
        self.clientId = clientId
        self.groupId = groupId
        
        if let myClientId = Backend.shared.getUserLogin()?.id, myClientId == clientId {
            self.userName = Backend.shared.getUserLogin()?.displayName ?? ""
        } else {
            fetchLocalUserName()
        }
    }
}
