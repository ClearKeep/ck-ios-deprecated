
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC
import SignalProtocolObjC
import NIOHPACK

class Backend: ObservableObject {
    
    static let shared = Backend()
    
    private let group: MultiThreadedEventLoopGroup
    
    private let clientSignal: Signal_SignalKeyDistributionClient
    
    private let clientAuth : Auth_AuthClient
    
    private let clientUser : User_UserClient
    
    private let clientGroup : Group_GroupClient
    
    private let connection: ClientConnection
    
    var authenticator: Authenticator
    
    var signalService: SignalService?
    
    private var queueHandShake: [String: String] = [:]
    
    
    @Published var messages: [PostModel] = []
    @Published var rooms = [RoomModel]()
    
    
    init(host: String = "172.16.0.216", port: Int = 5000) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let configuration = ClientConnection.Configuration.init(target: .hostAndPort(host, port), eventLoopGroup: group)
        
        connection = ClientConnection(configuration: configuration)
        
        clientSignal = Signal_SignalKeyDistributionClient(channel: connection)
        
        clientAuth = Auth_AuthClient(channel: connection)
        
        clientUser = User_UserClient(channel: connection)
        
        clientGroup = Group_GroupClient(channel: connection)
        
        authenticator = Authenticator(clientSignal)
        
        signalService = SignalService(clientSignal)
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
    
    func signalSubscrible(clientId: String) -> Void {
        signalService?.subscribe(clientId: clientId, completion: { [weak self] in
            self?.signalService?.listen(clientId: clientId, heard: self!.heard)
        })
    }
    
    private func heard(_ clienId: String, publication: Signal_Publication) {
        let userInfo: [String : Any] = ["clientId": clienId, "publication": publication]
        NotificationCenter.default.post(name: NSNotification.Name("DidReceiveSignalMessage"),
                                        object: nil,
                                        userInfo: userInfo)
        
    }
    
    func send(_ message: Data,
              fromClientId senderId: String,
              toClientId receiveId: String = "",
              groupId: String = "",
              _ completion: @escaping (Bool, Error?) -> Void) {
        do {
            let request: Signal_PublishRequest = .with {
                $0.clientID = receiveId
                $0.fromClientID = senderId
                $0.message = message
                $0.groupID = groupId
            }
            
            try self.sendMessage(request)
            
        } catch {
            print(error.localizedDescription)
        }
    }
        
    private func sendMessage(_ request: Signal_PublishRequest,
                        _ completion: ((Bool, Error?) -> Void)? = nil) throws {
        
        clientSignal.publish(request).response.whenComplete { result in
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
    
    func login(_ request: Auth_AuthReq, _ completion: @escaping (Auth_AuthRes?, Error?) -> Void){
        clientAuth.login(request).response.whenComplete { (result) in
            switch result {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func register(_ request: Auth_RegisterReq, _ completion: @escaping (Bool) -> Void){
        clientAuth.register(request).response.whenComplete { (result) in
            switch result {
            case .success(_):
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func getMyProfile(_ completion: @escaping (User_UserProfileResponse?, Error?) -> Void){
        let header = self.getHeaderApi()
        if let header = header {
            clientUser.get_profile(User_Empty(), callOptions: header).response.whenComplete { (result) in
                switch result {
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
    
    func getListUser(_ completion: @escaping (User_GetUsersResponse?, Error?) -> Void){
        let header = self.getHeaderApi()
        if let header = header {
            clientUser.get_users(User_Empty(), callOptions: header).response.whenComplete { (result) in
                switch result {
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
    
    func searchUser(_ keySearch: String, _ completion: @escaping (User_SearchUserResponse?, Error?) -> Void){
        let header = self.getHeaderApi()
        if let header = header {
            var req = User_SearchUserRequest()
            req.keyword = keySearch
            clientUser.search_user(req, callOptions: header).response.whenComplete { (result) in
                switch result {
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
    }
    
    func getJoinnedGroup(_ completion: @escaping (Group_GetJoinedGroupsResponse?, Error?) -> Void){
        let header = self.getHeaderApi()
        let userLogin = CKSignalCoordinate.shared.myAccount
        if let header = header , let userLogin = userLogin {
            var req = Group_GetJoinedGroupsRequest()
            req.clientID = userLogin.username
            clientGroup.get_joined_groups(req, callOptions: header).response.whenComplete { (result) in
                switch result {
                case .success(let response):
                    completion(response, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }

        }
    }
    
    func createRoom(_ req: Group_CreateGroupRequest, _ completion: @escaping (Group_GroupObjectResponse) -> Void){
        let header = self.getHeaderApi()
        if let header = header {
            clientGroup.create_group(req, callOptions: header).response.whenSuccess { (result) in
                    completion(result)
            }
        }
    }
    
    func getLoginUserID(_ completion: @escaping (String) -> Void) {
        let header = self.getHeaderApi()
        if let header = header {
            clientUser.get_profile(User_Empty(), callOptions: header).response.whenComplete { (result) in
                switch result {
                case .success(let response):
                    completion(response.id)
                case .failure(_):
                    completion("")
                }
            }
        }
    }
    
    private func getHeaderApi() -> CallOptions?{
        do {
            let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
            var header = HPACKHeaders()
            header.add(name: "access_token", value: userLogin.token)
            header.add(name: "hash_key", value: userLogin.hash)
            header.add(name: "domain", value: "localhost")
            header.add(name: "ip_address", value: "0.0.0.0")
            var option = CallOptions()
            option.customMetadata = header
            return option
        } catch {
            return nil
        }
    }
    
    private func getUserLogin() -> User?{
        do {
            let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
            return userLogin
        } catch {
            return nil
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
