//
//  AppDelegate.swift
//  elofy
//
//  Created by raptor on 23/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // keyboard manager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().disabledTouchResignedClasses.append(LikesVC.self)

        // register notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()

        // boot from notificaiton
        if let _ = launchOptions?[.remoteNotification] as? [String: Any],
            let _ = UserDefaults.standard.string(forKey: StoreKey.authToken.rawValue) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nav = storyboard.instantiateInitialViewController() as? UINavigationController
            nav?.pushViewController(storyboard.instantiateViewController(withIdentifier: "HomeVC"), animated: false)
            let tabVC = storyboard.instantiateViewController(withIdentifier: "TabVC") as! TabVC
            tabVC.page = TabPage.elos
            nav?.pushViewController(tabVC, animated: false)
            window?.rootViewController = nav
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("Device token for push notification >>> \(deviceTokenString)")

        // upload to server
        UserDefaults.standard.set(true, forKey: StoreKey.deviceTokenRefresh.rawValue)
        UserDefaults.standard.set(deviceTokenString, forKey: StoreKey.deviceToken.rawValue)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Receive remote notification >>> \(userInfo)")
    }
}


// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let _ = response.notification.request.content.userInfo

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let _ = UserDefaults.standard.string(forKey: StoreKey.authToken.rawValue) {
            let nav = storyboard.instantiateInitialViewController() as? UINavigationController
            nav?.pushViewController(storyboard.instantiateViewController(withIdentifier: "HomeVC"), animated: false)
            let tabVC = storyboard.instantiateViewController(withIdentifier: "TabVC") as! TabVC
            tabVC.page = TabPage.elos
            nav?.pushViewController(tabVC, animated: false)
            window?.rootViewController = nav
        } else {
            window?.rootViewController = storyboard.instantiateInitialViewController()
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert, .badge])
    }
}

