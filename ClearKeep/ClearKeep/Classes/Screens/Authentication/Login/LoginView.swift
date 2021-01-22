
import SwiftUI

let isGroupChat = true

struct LoginView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    @State var deviceID: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @EnvironmentObject var viewRouter: ViewRouter
    @State var isRegister: Bool = false
    @State var hudVisible = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TitleLabel("ClearKeep")
                    TextFieldContent(key: "Username", value: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    PasswordSecureField(password: $password)
                    HStack {
                        Button(action: login) {
                            ButtonContent("LOGIN")
                                .padding(.trailing, 25)
                        }
                        NavigationLink(destination: RegisterView(isPresentModel: $isRegister), isActive: $isRegister) {
                            Button(action: {
                                //                                register()
                                isRegister = true
                            }) {
                                ButtonContent("REGISTER")
                            }
                        }
                        
                    }
                }
                .padding()
                .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
            }
        }
    }
    
}

extension LoginView {
    
    private func register() {
        //        if isGroupChat {
        //            registerWithGroup()
        //        } else {
        //            registerByAddress()
        //        }
        self.viewRouter.current = .register
    }
    
    //    private func registerByAddress() {
    //        guard let deviceID: Int32 = Int32(deviceID) else {
    //            print("DeviceID always number")
    //            return
    //        }
    //        let address = SignalAddress(name: username, deviceId: Int32(deviceID))
    //        Backend.shared.authenticator.register(address: address) { (result, error) in
    //            print("Register result: \(result)")
    //            if result {
    //                Backend.shared.signalSubscrible(clientId: self.username)
    //                self.viewRouter.current = .masterDetail
    //            }
    //        }
    //    }
    
    private func registerWithGroup() {
        guard let deviceID: Int32 = Int32(deviceID),
              let myAccount = CKAccount(username: username, deviceId: deviceID, accountType: .none),
              let connectionDb = CKDatabaseManager.shared.database?.newConnection() else {
            print("DeviceID always number")
            return
        }
        let groupId: Int64 = 1234
        do {
            // save my Account
            connectionDb.readWrite { (transaction) in
                myAccount.save(with: transaction)
            }
            let ourSignalEncryptionMng = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId,
                                                                              databaseConnection: connectionDb)
            
            let address = SignalAddress(name: username, deviceId: deviceID)
            let groupSessionBuilder = SignalGroupSessionBuilder(context: ourSignalEncryptionMng.signalContext)
            let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
            let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
            
            CKSignalCoordinate.shared.ourEncryptionManager = ourSignalEncryptionMng
            CKSignalCoordinate.shared.myAccount = myAccount
            
            Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                       clientId: username,
                                                       deviceId: deviceID,
                                                       senderKeyData: signalSKDM.serializedData()) { (result, error) in
                print("Register group with result: \(result)")
                if result {
                    Backend.shared.signalSubscrible(clientId: self.username)
                    self.viewRouter.current = .masterDetail
                }
            }
        } catch {
            print("Register group error: \(error)")
        }
    }
}

extension LoginView {
    
    private func login() {
        //        CallManager.shared.startCall(clientId: "049fbb62-6666-493c-9628-db1149cca079",
        //                                     clientName: "Luan Nguyen",
        //                                     avatar: "",
        //                                     groupId: 1234,
        //                                     groupToken: "a1b2c3d4") //269a7a3fd8bc2e75785f
        //        hudVisible = true
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
        //            self.hudVisible = false
        //        }
        //        return
        hudVisible = true
        var request = Auth_AuthReq()
        request.username = self.username
        request.password = self.password
        request.authType = 1
        
        Backend.shared.login(request) { (result, error) in
            if let result = result {
                do {
                    var user = User(id: "", token: result.accessToken, hash: result.hashKey,userName: self.username)
                    try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
                    UserDefaults.standard.setValue(self.username, forKey: Constants.keySaveUserNameLogin)
                    Backend.shared.getLoginUserID { (userID) in
                        do {
                            if userID.isEmpty {
                                print("getLoginUserID Empty")
                                hudVisible = false
                                return
                            }
                            user.id = userID
                            try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
                            //                            let randomID = Int32.random(in: 1...Int32.max)
                            //TODO: hashcode device id
                            let address = SignalAddress(name: userID, deviceId: Int32(555))
                            Backend.shared.authenticator.register(address: address) { (result, error) in
                                if result {
                                    loginForUser(clientID: userID)
                                } else {
                                    print("Reigster Key Error \(error?.localizedDescription ?? "")")
                                    hudVisible = false
                                }
                            }
                        } catch {
                            print("save user error")
                            hudVisible = false
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    hudVisible = false
                }
            } else if let error = error {
                print(error)
                hudVisible = false
            }
        }
    }
    
    private func loginForUser(clientID : String) {
        Backend.shared.authenticator.requestKey(byClientId: clientID) { (result, error, response) in
            guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
            do {
                if let _ = response {
                    // save account
                    var myAccount: CKAccount?
                    dbConnection.readWrite({ (transaction) in
                        let accounts = CKAccount.allAccounts(withUsername: clientID,
                                                             transaction: transaction)
                        if accounts.count > 0 {
                            myAccount = accounts.first
                        } else {
                            myAccount?.save(with: transaction)
                        }
                    })
                    if let account = myAccount {
                        let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                        databaseConnection: dbConnection)
                        
                        CKSignalCoordinate.shared.myAccount = account
                        CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                    }
                    if result {
                        Backend.shared.registerTokenDevice { (response) in
                            if response {
                                hudVisible = false
                                self.viewRouter.current = .tabview
                            }
                        }
                    }else {
                        print("requestKey Error: \(error?.localizedDescription ?? "")")
                        hudVisible = false
                    }
                }
            } catch {
                print("Login with error: \(error)")
                hudVisible = false
            }
        }
    }
    
    private func updateUserInfo(responseUserKey: Signal_PeerGetClientKeyResponse, clientId: String) {
        guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
        do {
            // save account
            if let myAccount = CKAccount(username: responseUserKey.clientID, deviceId: responseUserKey.deviceID, accountType: .none) {
                // save account
                dbConnection.readWrite({ (transaction) in
                    myAccount.save(with:transaction)
                })
                
                let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId,
                                                                                databaseConnection: dbConnection)
                
                CKSignalCoordinate.shared.myAccount = myAccount
                CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                
                Backend.shared.registerTokenDevice { (response) in
                    if response {
                        hudVisible = false
                        self.viewRouter.current = .tabview
                    }
                }
            }
        } catch {
            print("Login with error: \(error)")
            hudVisible = false
        }
    }
    
    private func getLoginUserId(){
        
    }
    
    private func getSenderKeyInGroupTest() {
        let groupId: Int64 = 1234
        Backend.shared.authenticator.requestKeyGroup(byClientId: username, groupId: groupId) { (result, error, response) in
            guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
            do {
                // save account
                var myAccount: CKAccount?
                var isAddAccount = false
                dbConnection.readWrite({ (transaction) in
                    let accounts = CKAccount.allAccounts(withUsername: self.username, transaction: transaction)
                    if accounts.count > 0 {
                        myAccount = accounts.first
                    } else {
                        myAccount = CKAccount(username: self.username, deviceId: (response?.clientKey.deviceID)!, accountType: .none)
                        myAccount?.save(with: transaction)
                        isAddAccount = true
                    }
                })
                if let account = myAccount {
                    let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                    databaseConnection: dbConnection)
                    
                    CKSignalCoordinate.shared.myAccount = account
                    CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                    if isAddAccount,
                       let deviceId = response?.clientKey.deviceID,
                       let senderKeyData = response?.clientKey.clientKeyDistribution,
                       let senderId = response?.clientKey.clientID,
                       let groupId = response?.groupID {
                        let address = SignalAddress(name: senderId, deviceId: deviceId)
                        let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
                        if !ourEncryptionManager.senderKeyExistsForUsername(senderId, deviceId: deviceId, groupId: groupId) {
                            let _ = ourEncryptionManager.storage.storeSenderKey(senderKeyData, senderKeyName: senderKeyName)
                            //                            try ourEncryptionManager.consumeIncoming(toGroup: groupId, address: address, skdmDtata: senderKeyData)
                            
                        }
                    }
                }
                
                if result {
                    Backend.shared.signalSubscrible(clientId: self.username)
                    self.viewRouter.current = .tabview
                }
            } catch {
                print("Login with error: \(error)")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
