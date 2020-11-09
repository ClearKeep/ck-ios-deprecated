
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC
import SignalProtocolObjC

class Backend: ObservableObject {
    
    static let shared = Backend()
    
    private let group: MultiThreadedEventLoopGroup
    
    private let client: Signalc_SignalKeyDistributionClient
    private let clientGroup: SignalcGroup_GroupSenderKeyDistributionClient
    
    private let connection: ClientConnection
    
    var authenticator: Authenticator
    
    var signalService: SignalService?
    var heardCallback: ((String, Signalc_Publication) -> Void)?
    
    private var queueHandShake: [String: String] = [:]
    
    
    @Published var messages: [PostModel] = []
    @Published var rooms = [RoomModel]()
    
    
    init(host: String = "localhost", port: Int = 50052) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let configuration = ClientConnection.Configuration.init(target: .hostAndPort(host, port), eventLoopGroup: group)
        
        connection = ClientConnection(configuration: configuration)
        
        client = Signalc_SignalKeyDistributionClient(channel: connection)
        clientGroup = SignalcGroup_GroupSenderKeyDistributionClient(channel: connection)
        
        authenticator = Authenticator(client, clientGroup: clientGroup)
        
        signalService = SignalService(client, clientGroup: clientGroup)
        
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
    

    
    func close() {
        _ = connection.close()
    }
    
    
    static func log(_ string: String) {
        DispatchQueue.main.async {
            print(string)
        }
    }
    
    
    func authenticated(_ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {

//        signalService?.listen(heard: heard)
//        signalService?.subscribe(clientID: authenticator.clientStore.address.name, { (result, error, response) in
//
//        })
    }
    
    func subscrible(username: String) -> Void {
        signalService?.listen(username: username, heard: heard)
        signalService?.subscribe(clientID: username)
    }
    
    func subscribleGroup(username: String) -> Void {
        signalService?.listenGroup(username: username, heard: heardGroup)
        signalService?.subscribeGroup(clientID: username)
    }
    
    private func heard(_ clienID: String, publication: Signalc_Publication) {
        let userInfo: [String : Any] = ["clientId": clienID, "publication": publication]
        NotificationCenter.default.post(name: NSNotification.Name("DidReceiveMessage"),
                                        object: nil,
                                        userInfo: userInfo)
        
        // Save message
//        if authenticator.clientStore == nil {
//            return
//        }
//
//        let remoteAddress = SignalAddress(name: publication.senderID, deviceId: authenticator.recipientStore!.deviceID)
//
//        do {
//            let messageData = try authenticator.clientStore.decrypt(remoteAddress: remoteAddress, cipherData: publication.message)
//
//            let postModel = PostModel(from: publication.senderID, message: messageData)
//
//            self.messages.append(postModel)
//
//        } catch {
//            print(error)
//        }

    }
    private func heardGroup(_ clienID: String, publication: SignalcGroup_GroupPublication) {
        let userInfo: [String : Any] = ["clientId": clienID, "publication": publication]
        NotificationCenter.default.post(name: NSNotification.Name("DidReceiveMessageGroup"),
                                        object: nil,
                                        userInfo: userInfo)
        
    }
    
    
    func send(_ message: String,
              to recipient: String,
              _ completion: @escaping (Bool, Error?) -> Void) {
        
        guard let recipientStore = authenticator.recipientStore else {
            completion(false, nil)
            return
        }
        
        do {
            let remoteAddress = SignalAddress(name: recipientStore.clientID, deviceId: recipientStore.deviceID)
            
            let cipherText = try authenticator.clientStore.encrypt(remoteAddress: remoteAddress,
                                                                   recipientStore: authenticator.recipientStore!,
                                                                   message: message)
            
            let request: Signalc_PublishRequest = .with {
                $0.receiveID = recipient
                $0.senderID = authenticator.clientStore.address.name
                $0.message = cipherText.data
            }
            
            try self.send(request)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func send(_ message: Data,
              from ourUsername: String,
              to recipient: String,
              _ completion: @escaping (Bool, Error?) -> Void) {
        do {
            let request: Signalc_PublishRequest = .with {
                $0.receiveID = recipient
                $0.senderID = ourUsername
                $0.message = message
            }
            
            try self.send(request)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func send(toGroup groupId: String,
              message: Data,
              senderId: String,
              _ completion: @escaping (Bool, Error?) -> Void) {
        do {
            let request: SignalcGroup_GroupPublishRequest = .with {
                $0.groupID = groupId
                $0.senderID = senderId
                $0.message = message
            }
            
            try self.sendGroup(request)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func send(_ request: Signalc_PublishRequest,
                        _ completion: ((Bool, Error?) -> Void)? = nil) throws {
        
        client.publish(request).response.whenComplete { result in
            switch result {
            case .success(let response):
                print(response)
                completion?(false, nil)
            case .failure(let error):
                print(error)
                completion?(false, error)
            }
        }
    }
    
    private func sendGroup(_ request: SignalcGroup_GroupPublishRequest,
                        _ completion: ((Bool, Error?) -> Void)? = nil) throws {
        
        clientGroup.publish(request).response.whenComplete { result in
            switch result {
            case .success(let response):
                print(response)
                completion?(false, nil)
            case .failure(let error):
                print(error)
                completion?(false, error)
            }
        }
    }
}


struct PostModel: Identifiable {
    let id: Int8 = 11
    var newID = UUID().uuidString
    var from: String
    var message: Data
}

struct RoomModel: Identifiable, Hashable {
    var id: String

}
