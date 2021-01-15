
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC

class Authenticator {

    private let clientSignal: Signal_SignalKeyDistributionClient
        
    var recipientID: String = ""
    
    var clientStore: CKClientStore!
    
    init(_ clientSignal: Signal_SignalKeyDistributionClient) {
        self.clientSignal = clientSignal
    }
    
    func loggedIn() -> Bool {
        
        if clientStore == nil {
            return false
        }
        
        return true
    }
    
    private func groupRegisterClient(byClientId clientId: String,
                               groupId: Int64,
                               deviceId: Int32,
                               senderKeyData: Data,
                               _ completion: @escaping (Bool, Error?) -> Void,
                               submit: @escaping (Signal_GroupRegisterClientKeyRequest, CallOptions?)
                                -> UnaryCall<Signal_GroupRegisterClientKeyRequest, Signal_BaseResponse>) {
        let request: Signal_GroupRegisterClientKeyRequest = .with {
            $0.groupID = groupId
            $0.clientID = clientId
            $0.deviceID = deviceId
            $0.clientKeyDistribution = senderKeyData
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    Backend.shared.signalSubscrible(clientId: clientId)
                    completion(true, nil)
                case .failure(_):
                    completion(false, nil)
                }
            }
        }
    }
    
    // call register
    private func peerRegisterClient(byAddress address: SignalAddress,
                              _ completion: @escaping (Bool, Error?) -> Void,
                              submit: @escaping (Signal_PeerRegisterClientKeyRequest, CallOptions?)
                                -> UnaryCall<Signal_PeerRegisterClientKeyRequest, Signal_BaseResponse>) {
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
                let request: Signal_PeerRegisterClientKeyRequest = .with {
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
                            Backend.shared.signalSubscrible(clientId: clientId)
                            completion(true, nil)
                        case .failure(_):
                            completion(false, nil)
                        }
                    }
                }
            }
        } catch {
            print("registerUser error: \(error.localizedDescription)")
        }
    }
    
    private func groupGetClientKey(byClientId clientId: String,
                                    groupId: Int64,
                                 _ completion: @escaping (Bool, Error?, Signal_GroupGetClientKeyResponse?) -> Void,
                                 submit: @escaping (Signal_GroupGetClientKeyRequest, CallOptions?)
                                    -> UnaryCall<Signal_GroupGetClientKeyRequest, Signal_GroupGetClientKeyResponse>) {
        
        let request: Signal_GroupGetClientKeyRequest = .with {
            $0.groupID = groupId
            $0.clientID = clientId
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
    
    private func peerGetClientKey(byClientId clientId: String,
                            _ completion: @escaping (Bool, Error?, Signal_PeerGetClientKeyResponse?) -> Void,
                            submit: @escaping (Signal_PeerGetClientKeyRequest, CallOptions?)
                                -> UnaryCall<Signal_PeerGetClientKeyRequest, Signal_PeerGetClientKeyResponse>) {
        
        let request: Signal_PeerGetClientKeyRequest = .with {
            $0.clientID = clientId
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
    
    private func groupGetAllClientKey(byGroupId groupId: Int64,
                                      _ completion: @escaping (Bool, Error?, Signal_GroupGetAllClientKeyResponse?) -> Void,
                                      submit: @escaping (Signal_GroupGetAllClientKeyRequest, CallOptions?)
                                        -> UnaryCall<Signal_GroupGetAllClientKeyRequest, Signal_GroupGetAllClientKeyResponse>) {
        
        let request: Signal_GroupGetAllClientKeyRequest = .with {
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
    
    func register(address: SignalAddress, completion: @escaping (Bool, Error?) -> Void) {
        peerRegisterClient(byAddress: address, completion, submit: clientSignal.peerRegisterClientKey)
    }
    
    func registerGroup(byGroupId groupId: Int64,
                       clientId: String,
                       deviceId: Int32,
                       senderKeyData: Data,
                       completion: @escaping (Bool, Error?) -> Void) {
        groupRegisterClient(byClientId: clientId,
                            groupId: groupId,
                            deviceId: deviceId,
                            senderKeyData: senderKeyData,
                            completion,
                            submit: clientSignal.groupRegisterClientKey)
    }
    
}

extension Authenticator {
    
    
}

extension Authenticator {
    
    func requestKey(byClientId clientId: String,
                    _ completion: @escaping (Bool, Error?, Signal_PeerGetClientKeyResponse?) -> Void) {
        peerGetClientKey(byClientId: clientId, completion, submit: clientSignal.peerGetClientKey)
    }
    
    func requestKeyGroup(byClientId clientId: String,
                         groupId: Int64,
                         _ completion: @escaping (Bool, Error?, Signal_GroupGetClientKeyResponse?) -> Void) {
        groupGetClientKey(byClientId: clientId, groupId: groupId, completion, submit: clientSignal.groupGetClientKey)
    }
    
    func requestAllKeyInGroup(byGroup groupId: Int64,
                              _ completion: @escaping (Bool, Error?, Signal_GroupGetAllClientKeyResponse?) -> Void) {
        groupGetAllClientKey(byGroupId: groupId, completion, submit: clientSignal.groupGetAllClientKey)
    }
}

