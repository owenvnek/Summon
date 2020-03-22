//
//  AppDelegate.swift
//  Summon
//
//  Created by Owen Vnek on 12/22/19.
//  Copyright © 2019 Nio. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SocketIOManager.sharedInstance.establishConnection()
        print("established connection")
        // Override point for customization after application launch.
        FirebaseApp.configure()
        /**
        let labelAppearance = UILabel.appearance()
        labelAppearance.font = UIFont(name: "KohinoorTelugu-Medium", size: 17)
        let textFieldAppearance = UITextView.appearance()
        textFieldAppearance.font = UIFont(name: "KohinoorTelugu-Medium", size: 17)
        **/
        registerForPushNotifications()
        let notificationOption = launchOptions?[.remoteNotification]

        // 1
        if let notification = notificationOption as? [String: AnyObject],
          let aps = notification["aps"] as? [String: AnyObject] {
          print("tacos \(aps)")
        }
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: SummonUserContext.bold_font_name, size: 14.0)!],
                                for: .normal)
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Summon")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) {
          [weak self] granted, error in
            
          print("Permission granted: \(granted)")
          guard granted else { return }
          self?.getNotificationSettings()
      }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
        SummonUserContext.device_token = token
      print("Device Token: \(token)")
    }

    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }
    
    func application(
          _ application: UIApplication,
          didReceiveRemoteNotification userInfo: [AnyHashable: Any],
          fetchCompletionHandler completionHandler:
          @escaping (UIBackgroundFetchResult) -> Void
        ) {
          guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        print(aps)
        if SummonUserContext.tabbar_controller != nil {
            SummonUserContext.tabbar_controller!.selectedIndex = 0
        }
        if application.applicationState == .active {
            let alert_view = UIAlertController(title: "You received a Summon!", message: aps["alert"] as? String, preferredStyle: .alert)
            alert_view.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            if SummonUserContext.tabbar_controller != nil {
                SummonUserContext.tabbar_controller?.present(alert_view, animated: true, completion: nil)
            }
        }
        print(userInfo)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "queue"
        ]
        SocketIOManager.sharedInstance.send(event_name: "request_incoming_summons", items: data)
        print("Just requested queued summons")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let data = [
            "username": SummonUserContext.me!.get_username(),
            "source": "queue"
        ]
        SocketIOManager.sharedInstance.send(event_name: "request_incoming_summons", items: data)
        print("Just requested queued summons 2")
    }
    
}

