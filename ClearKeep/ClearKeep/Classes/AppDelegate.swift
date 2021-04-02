//
//  AppDelegate.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/6/20.
//

import UIKit
import UserNotifications
import PushKit
import CallKit
import GoogleSignIn

//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , PKPushRegistryDelegate, GIDSignInDelegate {
    let viewRouter = ViewRouter()
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        // Register VoIP push token (a property of PKPushCredentials) with server
        if type == .voIP {
            
        }
        
        let token = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1)})
        
        print("token: ------- \(token)")
        
        
        UserDefaults.standard.setValue(token, forKey: Constants.keySaveTokenPushNotify)
        
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.setValue(token, forKey: Constants.keySaveTokenPushNotifyAPNS)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:
                                    @escaping () -> Void) {
        
        // Always call the completion handler when done.
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                    @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        completionHandler(
            [UNNotificationPresentationOptions.alert,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.badge])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let content = UNMutableNotificationContent()
        content.title = userInfo[""] as? String ?? ""
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        if type == PKPushType.voIP {
            // check login
            if CKExtensions.getUserToken().isEmpty { return }
            if let notifiType = payload.dictionaryPayload["notify_type"] as? String {
                if notifiType == "cancel_request_call" {
                    if let roomId = payload.dictionaryPayload["group_id"] as? String {
                        let calls = CallManager.shared.calls.filter{$0.roomId == Int(roomId) ?? 0}
                        calls.forEach { (call) in
                            if call.isCallGroup {
                                // TODO: handle for group call
                            } else {
                                CallManager.shared.end(call: call)
                            }
                        }
                    }
                } else {
                    let backGroundTaskIndet = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                    CallManager.shared.handleIncomingPushEvent(payload: payload) { (_) in
                        UIApplication.shared.endBackgroundTask(backGroundTaskIndet)
                    }
                }
            }
        }
    }
    
    fileprivate func defaultConfig() -> CXProviderConfiguration{
        let config = CXProviderConfiguration(localizedName: "ClearKeep message")
        config.includesCallsInRecents = true
        config.supportsVideo = true
        config.maximumCallGroups = 5
        config.maximumCallsPerCallGroup = 10
        
        return config
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        CKDatabaseManager.shared.setupDatabase(withName: "CKDatabase.sqlite")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        // cheating fix callkit request failure in the first time
        let _ = CallManager.shared
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                self?.getNotificationSettings()
            }
        
        
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: .main)
        
        voipRegistry.delegate = self
        
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NetworkMonitor.shared.startMonitoring()
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = Constants.googleSignInClientId
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    @objc func applicationDidBecomeActive() {
        print("------------ become app")
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            Backend.shared.notificationSubscrible(clientId: myAccount.username)
            Backend.shared.signalSubscrible(clientId: myAccount.username)
            
            let userInfo = Dictionary<AnyHashable, Any>()
            NotificationCenter.default.post(name: NSNotification.AppBecomeActive,
                                            object: nil,
                                            userInfo: userInfo)
        }
    }
    
    @objc func applicationDidEnterBackground() {
        print("------------ enter background app")
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            Backend.shared.signalUnsubcrible(clientId: myAccount.username)
            Backend.shared.notificationUnSubscrible(clientId: myAccount.username)
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        
        
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            let userInfo: [String : Any] = ["error": error]
            NotificationCenter.default.post(name: NSNotification.GoogleSignIn.FinishedWithError,
                                            object: nil,
                                            userInfo: userInfo)
            return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
        // ...
        
        print("UserId: \(userId!)")
        print("idToken: \(idToken!)")
        print("email: \(email!)")
        
        if let gUser = user {
            let userInfo: [String : Any] = ["user": gUser]
            NotificationCenter.default.post(name: NSNotification.GoogleSignIn.FinishedWithResponse,
                                            object: nil,
                                            userInfo: userInfo)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

extension AppDelegate : CXProviderDelegate {
    func providerDidReset( _ provider: CXProvider) {
        
    }
    
    
}

