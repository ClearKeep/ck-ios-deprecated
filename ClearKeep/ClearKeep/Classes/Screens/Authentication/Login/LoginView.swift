
import SwiftUI
import Combine

import SwiftProtobuf
import NIO
import GRPC
import SignalProtocol

struct LoginView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    @State var senderId: String = ""
    @State var senderDeviceId: String = ""
    @State var senderInputDeviceId: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    
    @State private var signalAddress:SignalAddress? = nil
    
    let bobStore = CKBundleStore()
    //    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            TitleLabel("ClearKeep")
            UserImage(name: "phone")
            TextFieldContent(key: "Username", value: $username)
                .autocapitalization(.none)
            TextFieldContent(key: "SenderId", value: $senderId)
                .autocapitalization(.none)
            TextFieldContent(key: "SenderId", value: $senderInputDeviceId)
                .autocapitalization(.none)
            TitleLabel(senderDeviceId)
                .autocapitalization(.none)
            HStack {
                Button(action: login) {
                    ButtonContent("LOGIN")
                        .padding(.trailing, 25)
                }
                Button(action: register) {
                    ButtonContent("REGISTER")
                }
            }
        }
        .padding()
    }
}

extension LoginView {
    private func register() {
        do {
            // Create the identity key ata install time
            let identity = try SignalCrypto.generateIdentityKeyPair()
            
            bobStore.identityKeyStore.store(identityKeyData: identity)
            
            let preKeys: [Data] = try bobStore.createPreKeys(count: 10)
            
            try bobStore.preKeyStore.store(preKey: preKeys.last!, for: 9)
            
            let signedPreKey = try bobStore.updateSignedPrekey()
            
            try bobStore.signedPreKeyStore.store(signedPreKey: signedPreKey, for: 22)
            
        } catch {
            print(error.localizedDescription)
        }
        print("user name \(username)")
        let deviceId = Int(random(digits: 3)) ?? 0
        senderDeviceId = String(describing: deviceId)
        self.signalAddress = SignalAddress(identifier: username, deviceId: 111)
        // Upload publicKey, preKeys, and signedPreKey to the server
        Backend.shared.authenticator.register(self.signalAddress!, bundleStore: bobStore) { (result, error) in
            print("----------- son print result-----------")
            print(result ?? "fail")
        }
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
            number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
}

extension LoginView {
    
    private func login() {
        Backend.shared.authenticator.login(username) { (result, error) in
            if let res:Signalc_SignalKeysUserResponse = result as? Signalc_SignalKeysUserResponse {
                print("----------- son print result-----------")
                print(res.clientID)
                self.testCreatePreKeyBundle(res)
                self.gotoHome()
                self.fetch()
            }
        }
    }
    
    private func fetch() {
        Backend.shared.signalService.listen(heard: heard)
    }
    
    private func heard(_ senderId: String, _ response: Signalc_Publication) {
        print("heard from backend")
        do {
            let aliceSignalAddress = SignalAddress(identifier: senderId, deviceId: 111)
            Backend.shared.authenticator.login(senderId) { (result, error) in
                if let res:Signalc_SignalKeysUserResponse = result as? Signalc_SignalKeysUserResponse {
                    self.readTestCreatePreKeyBundle(res,response)
                }
            }
        } catch  {
            return
        }
        
    }
    
    private func readTestCreatePreKeyBundle(_ result: Signalc_SignalKeysUserResponse, _ response: Signalc_Publication) {
            do {
                let preKeyBundle = try SessionPreKeyBundle(preKey: result.preKey, signedPreKey: result.signedPreKey, identityKey: result.identityKeyPublic)
                let aliceSignalAddress = SignalAddress(identifier: senderId, deviceId: 111)
                let session = SessionCipher(store: bobStore, remoteAddress: aliceSignalAddress)
                try session.process(preKeyBundle: preKeyBundle)
                
                guard let incomingMessage = try? PreKeySignalMessage(from: response.message) else {
                    print("Could not deserialize PreKeySignalMessage")
                    return
                }
                
                guard let plaintext = try? session.decrypt(preKeySignalMessage: incomingMessage) else {
                    print("Could not decrypt message")
                    return
                }
                print("replyMessage")
                print(plaintext)
            } catch {
                return
            }
        }
    
    private func gotoHome() {
        
    }
    
    private func testCreatePreKeyBundle(_ result: Signalc_SignalKeysUserResponse) {
        do {
            
            //            let request: Signalc_SignalRegisterKeysRequest = .with {
            //                $0.clientID = signalAddess.identifier
            //                $0.deviceID = Int32(signalAddess.deviceId)
            //                $0.identityKeyPublic = try! bundleStore.identityKeyStore.getIdentityKeyPublicData()
            //                $0.registrationID = Int32(bundleStore.preKeyStore.lastId)
            //                $0.preKey = try! bundleStore.preKeyStore.preKey(for: bundleStore.preKeyStore.lastId)
            //                $0.signedPreKeyID = Int32(bundleStore.signedPreKeyStore.lastId)
            //                $0.signedPreKey = try! bundleStore.signedPreKeyStore.signedPreKey(for: bundleStore.signedPreKeyStore.lastId)
            //            }
            
            let preKeyBundle = try SessionPreKeyBundle(preKey: result.preKey, signedPreKey: result.signedPreKey, identityKey: result.identityKeyPublic)
            let aliceSignalAddress = SignalAddress(identifier: senderId, deviceId: 111)
            let session = SessionCipher(store: bobStore, remoteAddress: aliceSignalAddress)
            try session.process(preKeyBundle: preKeyBundle)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let today = Date()
            // The message to encrypt
            let message = ("Hello Bob, it's Alice \(dateFormatter.string(from: today))").data(using: .utf8)!
            
            //            // Here Alice can send messages to Bob
            //            let encryptedMessage = try session.encrypt(message)
            
            /* Encrypt a reply from Bob */
            //            let bobReply = "This is a message from Bob.".data(using: .utf8)!
            guard let replyMessage = try? session.encrypt(message) else {
                print("Could not encrypt reply from Bob")
                return
            }
            
            
//            guard let incomingMessage = try? PreKeySignalMessage(from: replyMessage.data) else {
//                print("Could not deserialize PreKeySignalMessage")
//                return
//            }
//
//            //            let aliceSignalAddress = SignalAddress(identifier: senderId, deviceId: 111)
//            //            let bobSessionCipher = SessionCipher(store: bobStore, remoteAddress: aliceSignalAddress)
//
//            guard let plaintext = try? session.decrypt(preKeySignalMessage: incomingMessage) else {
//                print("Could not decrypt message")
//                return
//            }
//            print("replyMessage")
//            print(plaintext)
            Backend.shared.authenticator.pushMessage(result.clientID, senderId, replyMessage.data) { (result, error) in
                print("pushMessage")
                print(result ?? "fail")
            }
        } catch {
            return
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
