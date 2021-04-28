//
//  AppDelegate.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit
import UserNotifications
import Firebase
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var unNotification : UserNotification = UserNotification()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        FirebaseApp.configure()
//        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        if UserDefaults.standard.object(forKey: "notiOn") == nil {
            UserDefaults.standard.set(true, forKey: "notiOn")
        }
        
        self.unNotification.enableUserNotification { _ -> (Void) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications() //최초 푸시 사용 여부 표시용..
            }
        }
        return true
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

