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

//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , PKPushRegistryDelegate {
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
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        
        //        let content = UNMutableNotificationContent()
        //        content.title = "Notification Title"
        //        content.subtitle = ""
        //        content.body = "message"
        //        content.sound = UNNotificationSound.default
        //
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //
        //        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        //        UNUserNotificationCenter.current().add(request)
        
        if type == PKPushType.voIP {
//            self.incomingCall()
            let backGroundTaskIndet = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            self.displayIncomingCall(handle: "handle", hasVideo: true){ _ in
                UIApplication.shared.endBackgroundTask(backGroundTaskIndet)
            }
        }
        
        
        print("co push")
    }
    
    func displayIncomingCall(handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        CallManager.shared.reportIncomingCall(uuid: UUID(), handle: handle, hasVideo: true, completion: completion)
    }
    
    fileprivate func defaultConfig() -> CXProviderConfiguration{
        let config = CXProviderConfiguration(localizedName: "ClearKeep message")
        config.includesCallsInRecents = true
        config.supportsVideo = true
        config.maximumCallGroups = 5
        config.maximumCallsPerCallGroup = 10
        
        return config
    }
    
    func incomingCall(){
        let provider = CXProvider(configuration: defaultConfig())
        provider.setDelegate(self, queue: .none)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "ClearKeep")
        update.hasVideo = true
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        CKDatabaseManager.shared.setupDatabase(withName: "CKDatabase.sqlite")
        // fake token registered
        UserDefaults.standard.setValue(UUID().uuidString, forKey: Constants.keySaveTokenPushNotify)
        
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
        
        
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: .main)
        
        voipRegistry.delegate = self
        
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        return true
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
    
    
}

extension AppDelegate : CXProviderDelegate {
    func providerDidReset( _ provider: CXProvider) {
        
    }
    
    
}

