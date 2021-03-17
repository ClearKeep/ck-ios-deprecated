//
//  NetworkMonitor.swift
//  ClearKeep
//
//  Created by Seoul on 3/8/21.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .satisfied
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            if self?.status != path.status {
                self?.status = path.status
                self?.isReachableOnCellular = path.isExpensive

                if path.status == .satisfied {
                    print("We're connected!")
                    // post connected notification
                    DispatchQueue.main.async {
                        if let myAccount = CKSignalCoordinate.shared.myAccount {
                            Backend.shared.notificationSubscrible(clientId: myAccount.username)
                            Backend.shared.signalSubscrible(clientId: myAccount.username)
                        }
                    }
                } else {
                    print("No connection.")
                    // post disconnected notification
                }
            }
            
            print(path.isExpensive)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
