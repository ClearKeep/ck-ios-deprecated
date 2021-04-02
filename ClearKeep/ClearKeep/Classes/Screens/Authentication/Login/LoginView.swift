
import SwiftUI
import GoogleSignIn

struct LoginView: View {

    @EnvironmentObject var viewRouter: ViewRouter

    @State var email: String = ""
    @State var password: String = ""
    @State var deviceID: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @State var isRegister: Bool = false
    @State var isForgotPassword: Bool = false
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    @State private var isEmailValid : Bool = true
    @State private var isPasswordValid: Bool = true
    
    let ggSignInBtn: GIDSignInButton = GIDSignInButton()
    
    @State private var colorBorder = Color.gray
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { reader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(alignment: .center) {
                            TitleLabel("ClearKeep")
                            Image("ic_app")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100, alignment: .center)
                                .padding(.bottom, 20)
                            VStack(alignment: .leading , spacing: 10){
                                TitleTextField("Email")
                                TextField("", text: $email, onEditingChanged: { (isChanged) in
                                    if !isChanged {
                                        self.isEmailValid = self.email.textFieldValidatorEmail()
                                        colorBorder = self.isEmailValid ? Color.gray : Color.red
                                    }
                                })
                                .keyboardType(.emailAddress)
                                .font(.system(size: 20))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .frame(height: 50)
                                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(colorBorder, lineWidth: 1))
                                .textFieldStyle(MyTextFieldStyle())
                                .padding([.leading , .trailing], 1)

                                .onAppear {
                                    self.isEmailValid = true
                                }
                                if !self.isEmailValid {
                                    Text("Email is invalid")
                                        .font(Font.system(size: 13))
                                        .foregroundColor(Color.red)
                                }
                                TitleTextField("Password")
                                    .padding(.top , 10)
                                SecureInputView("", text: $password)
                                    .frame(height: 50)
                                    .textFieldStyle(MyTextFieldStyle())
                                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.gray, lineWidth: 1))
                                    .padding([.leading , .trailing], 1)
                                    .padding(.bottom, 10)
                                
                                Button(action: login) {
                                    Text("Login")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(minWidth: 0, maxWidth: .infinity , minHeight: 50, idealHeight: 50)
                                        .background(Color("Blue-2"))
                                }
                                .cornerRadius(10)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            }
                            
                            NavigationLink(destination: RegisterView(isPresentModel: $isRegister), isActive: $isRegister) {
                                Button(action: {
                                    isRegister = true
                                }) {
                                    Text("Register")
                                        .underline()
                                        .foregroundColor(.blue)
                                    //                                        .frame(minWidth: 0, maxWidth: .infinity , minHeight: 40, idealHeight: 40)
                                    //                                        .background(Color("Blue"))
                                }
                                //                                .cornerRadius(10)
                                .frame(width: UIScreen.main.bounds.width - 40, height: 30, alignment: .trailing)
                            }
                            
                            VStack {
                                GoogleSignInButton(signBtn: ggSignInBtn)
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 52, alignment: .center)
                                    .onTapGesture {
                                        SocialLogin().attemptLoginGoogle()
                                    }
                            }
                        }
                    })
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .keyboardManagment()
            .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
            .alert(isPresented: self.$isShowAlert, content: {
                Alert(title: Text("Login Error"),
                      message: Text(self.messageAlert),
                      dismissButton: .default(Text("OK")))
            })
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        UIApplication.shared.endEditing()
                    })
            .padding()
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.GoogleSignIn.FinishedWithResponse)) { (obj) in
                if let userInfo = obj.userInfo,
                   let user = userInfo["user"] as? GIDGoogleUser {
                    print("Google signin success for user \(user.profile.email ?? "")")
                    self.loginWithGoogleSignInResponse(gooleUser: user)
                    SocialLogin().signOutGoogleAccount()
                }
            }
        }
    }
    
}

extension LoginView {
    
    private func register() {
        self.viewRouter.current = .register
    }
    
    private func registerWithGroup() {
        guard let deviceID: Int32 = Int32(deviceID),
              let myAccount = CKAccount(username: email, deviceId: deviceID, accountType: .none),
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
            
            let address = SignalAddress(name: email, deviceId: deviceID)
            let groupSessionBuilder = SignalGroupSessionBuilder(context: ourSignalEncryptionMng.signalContext)
            let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
            let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
            
            CKSignalCoordinate.shared.ourEncryptionManager = ourSignalEncryptionMng
            CKSignalCoordinate.shared.myAccount = myAccount
            
            Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                       clientId: email,
                                                       deviceId: deviceID,
                                                       senderKeyData: signalSKDM.serializedData()) { (result, error) in
                print("Register group with result: \(result)")
                if result {
                    //                    Backend.shared.signalSubscrible(clientId: self.email)
                    self.viewRouter.current = .masterDetail
                }
            }
        } catch {
            print("Register group error: \(error)")
        }
    }
}

// MARK: - Google SignIn Button
extension LoginView {
    
    private func loginWithGoogleSignInResponse(gooleUser: GIDGoogleUser) {
        hudVisible = true
        var request = Auth_GoogleLoginReq()
        request.idToken = gooleUser.authentication.idToken
        
        Backend.shared.loginWithGoogleAccount(request) { (result, error) in
            self.didReceiveLoginResponse(result: result, error: error)
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
        
        self.isEmailValid = self.email.textFieldValidatorEmail()
        colorBorder = self.isEmailValid ? Color.gray : Color.red
        
        if self.email.isEmpty {
            self.messageAlert = "Email can't be empty"
            self.isShowAlert = true
            return
        } else if !self.isEmailValid {
            return
        } else if self.password.isEmpty {
            self.isPasswordValid = false
            self.messageAlert = "Password can't be empty"
            self.isShowAlert = true
            return
        }
        
        hudVisible = true
        var request = Auth_AuthReq()
        request.email = self.email
        request.password = self.password
        request.authType = 1    // Which values could be set here?
        
        Backend.shared.login(request) { (result, error) in
            self.didReceiveLoginResponse(result: result, error: error)
        }
    }
    
    private func didReceiveLoginResponse(result: Auth_AuthRes?, error: Error?) {
        if let result = result {
            if result.baseResponse.success{
                do {
                    var user = User(id: "", token: result.accessToken, hash: result.hashKey,displayName: "" , email: self.email)
                    UserDefaults.standard.setValue(result.refreshToken, forKey: Constants.keySaveRefreshToken)
                    try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
                    
                    Backend.shared.getLoginUserID { (userID, displayName) in
                        do {
                            if userID.isEmpty {
                                print("getLoginUserID Empty")
                                UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                                UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
                                hudVisible = false
                                self.messageAlert = "Something went wrong"
                                self.isShowAlert = true
                                return
                            }
                            user.id = userID
                            user.displayName = displayName
                            UserDefaults.standard.setValue(user.id, forKey: Constants.keySaveUserID)
                            try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
                            //                            let randomID = Int32.random(in: 1...Int32.max)
                            //TODO: hashcode device id
                            let address = SignalAddress(name: userID, deviceId: Int32(555))
                            Backend.shared.authenticator.register(address: address) { (result, error) in
                                if result {
                                    loginForUser(clientID: userID)
                                } else {
                                    print("Register Key Error \(error?.localizedDescription ?? "")")
                                    UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                                    UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
                                    hudVisible = false
                                    self.messageAlert = "Something went wrong"
                                    self.isShowAlert = true
                                }
                            }
                        } catch {
                            print("save user error")
                            UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                            UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
                            hudVisible = false
                            self.messageAlert = "Something went wrong"
                            self.isShowAlert = true
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                    UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
                    hudVisible = false
                    self.messageAlert = "Something went wrong"
                    self.isShowAlert = true
                }
            }else {
                hudVisible = false
                self.isShowAlert = true
                self.messageAlert = result.baseResponse.errors.message
            }
        } else if let error = error {
            print(error)
            self.messageAlert = "Something went wrong"
            self.isShowAlert = true
            hudVisible = false
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
                        Backend.shared.signalSubscrible(clientId: account.username)
                        Backend.shared.notificationSubscrible(clientId: account.username)
                    }
                    if result {
                        Backend.shared.registerTokenDevice { (response) in
                            if response {
                                UserDefaults.standard.setValue(Date(), forKey: Constants.User.loginDate)
                                hudVisible = false
                                self.viewRouter.current = .tabview
                            }else {
                                UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                                hudVisible = false
                                self.messageAlert = "Something went wrong"
                                self.isShowAlert = true
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
