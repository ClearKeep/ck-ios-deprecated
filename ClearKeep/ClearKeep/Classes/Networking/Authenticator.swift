
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC

class Authenticator {
    
    private let client: Signalc_SignalKeyDistributionClient
    private let clientGroup: SignalcGroup_GroupSenderKeyDistributionClient
    
    var recipientStore: Signalc_SignalKeysUserResponse?
    
    var recipientID: String = ""
    
    var clientStore: CKClientStore!
    
    init(_ client: Signalc_SignalKeyDistributionClient,
         clientGroup: SignalcGroup_GroupSenderKeyDistributionClient) {
        self.client = client
        self.clientGroup = clientGroup
    }
    
    func loggedIn() -> Bool {
        
        if clientStore == nil {
            return false
        }
        
        return true
    }
    
    // call register
    private func authenticate(bundleStore: CKClientStore,
                              _ completion: @escaping (Bool, Error?) -> Void,
                              submit: @escaping (Signalc_SignalRegisterKeysRequest, CallOptions?)
                                -> UnaryCall<Signalc_SignalRegisterKeysRequest, Signalc_BaseResponse>) {
        
        
        let request: Signalc_SignalRegisterKeysRequest = .with {
            $0.clientID = bundleStore.address.name
            $0.deviceID = bundleStore.address.deviceId
            $0.registrationID = bundleStore.localRegistrationId
            $0.identityKeyPublic = bundleStore.identityKeyPair.publicKey
            $0.preKeyID = Int32(bundleStore.preKey1.preKeyId)
            $0.preKey = bundleStore.preKey1.serializedData()!
            $0.signedPreKeyID = Int32(bundleStore.signedPreKey.preKeyId)
            $0.signedPreKey = bundleStore.signedPreKey.serializedData()!
            $0.signedPreKeySignature = bundleStore.signedPreKey.signature
        }
        
        submit(request, nil).response.whenComplete { (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    completion(true, nil)
                case .failure(_):
                    self.authenticated(cliendID: "") { (_, _, _) in
                        
                    }
                }
            }
        }
    }
    
    // call register
    private func registerUser(byAddress address: SignalAddress,
                              _ completion: @escaping (Bool, Error?) -> Void,
                              submit: @escaping (Signalc_SignalRegisterKeysRequest, CallOptions?)
                                -> UnaryCall<Signalc_SignalRegisterKeysRequest, Signalc_BaseResponse>) {
        do {
            if let connectionDb = CKDatabaseManager.shared.database?.newConnection(),
               let myAccount = CKAccount(username: address.name, deviceId: address.deviceId, accountType: .none) {
                // save account
                connectionDb.readWrite({ (transaction) in
                    myAccount.save(with:transaction)
                })
                let ourSignalEncryptionMng = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId,
                                                                                  databaseConnection: connectionDb)
                let clientId = address.name
                let ckBundle = try ourSignalEncryptionMng.generateOutgoingBundle(1)
                let preKey = ckBundle.preKeys.first
                
                CKSignalCoordinate.shared.myAccount = myAccount
                CKSignalCoordinate.shared.ourEncryptionManager = ourSignalEncryptionMng
                
                // register request only public key (preKey, signedPreKey)
                //                let request: Signalc_SignalRegisterKeysRequest = .with {
                //                    $0.clientID = clientId
                //                    $0.deviceID = Int32(address.deviceId)
                //                    $0.registrationID = Int32(ckBundle.deviceId)
                //                    $0.identityKeyPublic = ckBundle.identityKey
                //                    $0.preKeyID = Int32(preKey!.preKeyId)
                //                    $0.preKey = preKey!.publicKey
                //                    $0.signedPreKeyID = Int32(ckBundle.signedPreKey.preKeyId)
                //                    $0.signedPreKey = ckBundle.signedPreKey.publicKey
                //                    $0.signedPreKeySignature = ckBundle.signedPreKey.signature
                //                }
                
                // register request with public and private key (preKey, signedPreKey)
                let request: Signalc_SignalRegisterKeysRequest = .with {
                    $0.clientID = clientId
                    $0.deviceID = Int32(address.deviceId)
                    $0.registrationID = Int32(ourSignalEncryptionMng.registrationId)
                    $0.identityKeyPublic = ckBundle.identityKey
                    $0.preKeyID = Int32(ourSignalEncryptionMng.myPreKey!.preKeyId)
                    $0.preKey = (ourSignalEncryptionMng.myPreKey?.serializedData())!
                    $0.signedPreKeyID = Int32(ourSignalEncryptionMng.mySignalPreKey!.preKeyId)
                    $0.signedPreKey = (ourSignalEncryptionMng.mySignalPreKey?.serializedData())!
                    $0.signedPreKeySignature = ckBundle.signedPreKey.signature
                }
                
                submit(request, nil).response.whenComplete { (result) in
                    
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            print(response)
                            Backend.shared.subscrible(username: clientId)
                            completion(true, nil)
                        case .failure(_):
                            self.authenticated(cliendID: "") { (_, _, _) in
                                
                            }
                        }
                    }
                }
            }
        } catch {
            print("registerUser error: \(error.localizedDescription)")
        }
    }
    
    private func registerGroup(byGroupId groupId: String,
                               clientId: String,
                               deviceId: Int32,
                               senderKeyData: Data,
                               _ completion: @escaping (Bool, Error?) -> Void,
                               submit: @escaping (SignalcGroup_GroupRegisterSenderKeyRequest, CallOptions?)
                                -> UnaryCall<SignalcGroup_GroupRegisterSenderKeyRequest, SignalcGroup_GroupRegisterSenderKeyResponse>) {
        let request: SignalcGroup_GroupRegisterSenderKeyRequest = .with {
            $0.groupID = groupId
            $0.clientID = clientId
            $0.deviceID = deviceId
            $0.senderKeyDistribution = senderKeyData
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    Backend.shared.subscribleGroup(username: clientId)
                    completion(true, nil)
                case .failure(_):
                    self.authenticated(cliendID: "") { (_, _, _) in
                        
                    }
                }
            }
        }
    }
    
    
    private func authenticated(cliendID: String,
                               _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        
        if recipientID.isEmpty || recipientStore == nil {
            Backend.shared.authenticated(completion)
        }
    }
    
    
    private func nauthenticate(_ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        print("auth failed")
        recipientID = ""
        completion(false, nil, nil)
    }
    
    
    private func login(_ clientID: String,
                       _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void,
                       submit: @escaping (Signalc_SignalKeysUserRequest, CallOptions?)
                        -> UnaryCall<Signalc_SignalKeysUserRequest, Signalc_SignalKeysUserResponse>) {
        
        let request: Signalc_SignalKeysUserRequest = .with {
            $0.clientID = clientID
        }
        
        submit(request, nil).response.whenComplete { (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    Backend.shared.subscrible(username: clientID)
                    completion(true, nil, response)
                case .failure(_):
                    self.nauthenticate(completion)
                }
            }
        }
    }
    
    // Test check regsiter key in group
    private func checkRegisterInGroup(bySenderId senderId: String,
                                      groupId: String,
                                      _ completion: @escaping (Bool, Error?, SignalcGroup_GroupGetSenderKeyResponse?) -> Void,
                                      submit: @escaping (SignalcGroup_GroupGetSenderKeyRequest, CallOptions?)
                                        -> UnaryCall<SignalcGroup_GroupGetSenderKeyRequest, SignalcGroup_GroupGetSenderKeyResponse>) {
        
        let request: SignalcGroup_GroupGetSenderKeyRequest = .with {
            $0.groupID = groupId
            $0.senderID = senderId
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    Backend.shared.subscribleGroup(username: senderId)
                    completion(true, nil, response)
                case .failure(_):
                    completion(false, nil, nil)
                }
            }
        }
    }
    
    private func requestKey(byClientID clientID: String,
                            _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void,
                            submit: @escaping (Signalc_SignalKeysUserRequest, CallOptions?)
                                -> UnaryCall<Signalc_SignalKeysUserRequest, Signalc_SignalKeysUserResponse>) {
        
        let request: Signalc_SignalKeysUserRequest = .with {
            $0.clientID = clientID
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(true, nil, response)
                case .failure(_):
                    completion(false, nil, nil)
                }
            }
        }
    }
    
    private func requestKeyGroup(bySenderId senderId: String, groupId: String,
                                 _ completion: @escaping (Bool, Error?, SignalcGroup_GroupGetSenderKeyResponse?) -> Void,
                                 submit: @escaping (SignalcGroup_GroupGetSenderKeyRequest, CallOptions?)
                                    -> UnaryCall<SignalcGroup_GroupGetSenderKeyRequest, SignalcGroup_GroupGetSenderKeyResponse>) {
        
        let request: SignalcGroup_GroupGetSenderKeyRequest = .with {
            $0.groupID = groupId
            $0.senderID = senderId
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(true, nil, response)
                case .failure(_):
                    completion(false, nil, nil)
                }
            }
        }
    }
    
    private func requestAllKeyInGroup(byGroupId groupId: String,
                                      _ completion: @escaping (Bool, Error?, SignalcGroup_GroupGetAllSenderKeyResponse?) -> Void,
                                      submit: @escaping (SignalcGroup_GroupGetAllSenderKeyRequest, CallOptions?)
                                        -> UnaryCall<SignalcGroup_GroupGetAllSenderKeyRequest, SignalcGroup_GroupGetAllSenderKeyResponse>) {
        
        let request: SignalcGroup_GroupGetAllSenderKeyRequest = .with {
            $0.groupID = groupId
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(true, nil, response)
                case .failure(_):
                    completion(false, nil, nil)
                }
            }
        }
    }
}

extension Authenticator {
    
    func register(bundleStore: CKClientStore, completion: @escaping (Bool, Error?) -> Void) {
        authenticate(bundleStore: bundleStore, completion, submit: client.registerBundleKey)
    }
    
    func register(address: SignalAddress, completion: @escaping (Bool, Error?) -> Void) {
        registerUser(byAddress: address, completion, submit: client.registerBundleKey)
    }
    
    func registerGroup(byGroupId groupId: String,
                       clientId: String,
                       deviceId: Int32,
                       senderKeyData: Data,
                       completion: @escaping (Bool, Error?) -> Void) {
        registerGroup(byGroupId: groupId,
                      clientId: clientId,
                      deviceId: deviceId,
                      senderKeyData: senderKeyData,
                      completion, submit: clientGroup.registerSenderKeyGroup)
    }
    
}

extension Authenticator {
    
    func login(_ clientID: String,
               _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        login(clientID, completion, submit: client.getKeyBundleByUserId)
    }
    
    func checkRegisterInGroup(groupId: String,
                              clientId: String,
                              completion: @escaping (Bool, Error?, SignalcGroup_GroupGetSenderKeyResponse?) -> Void) {
        checkRegisterInGroup(bySenderId: clientId,
                             groupId: groupId,
                             completion,
                             submit: clientGroup.getSenderKeyInGroup)
    }
}

extension Authenticator {
    
    func requestKey(byClientID clientID: String,
                    _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        requestKey(byClientID: clientID,
                   completion,
                   submit: client.getKeyBundleByUserId)
    }
    
    func requestKeyGroup(bySenderId senderId: String,
                         groupId: String,
                         _ completion: @escaping (Bool, Error?, SignalcGroup_GroupGetSenderKeyResponse?) -> Void) {
        requestKeyGroup(bySenderId: senderId,
                        groupId: groupId,
                        completion,
                        submit: clientGroup.getSenderKeyInGroup)
    }
    
    func requestAllKeyInGroup(byGroup groupId: String,
                              _ completion: @escaping (Bool, Error?, SignalcGroup_GroupGetAllSenderKeyResponse?) -> Void) {
        requestAllKeyInGroup(byGroupId: groupId,
                             completion,
                             submit: clientGroup.getAllSenderKeyInGroup)
    }
}

