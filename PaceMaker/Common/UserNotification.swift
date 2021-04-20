//
//  UserNotification.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/20.
//

import UIKit
import UserNotifications

class UserNotification : NSObject {
    func enableUserNotification(completion: ((Bool) -> (Void))? ) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { [weak self] (granted, _) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
                completion?(true)
                return
            }
            completion?(false)
        }
    }
    
    func sendNotification(seconds: Double) {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = "Are you walking?"
        notificationContent.body = "Hang in there, keep runnung!"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}

@available(iOS 10, *)
//https://medium.com/the-guardian-mobile-innovation-lab/how-to-replace-the-content-of-an-ios-notification-2d8d93766446
extension UserNotification : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

