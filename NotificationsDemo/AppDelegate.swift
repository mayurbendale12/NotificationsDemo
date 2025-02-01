import UIKit

enum Identifiers {
  static let viewAction = "VIEW_IDENTIFIER"
  static let newsCategory = "NEWS_CATEGORY"
}

//Use command to simulate push notifications
//xcrun simctl push 05C0FFD7-445A-45D9-838A-9FC5645C430A com.msb.NotificationsDemo first.apn
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    //If app is not running and user launches it by tapping on push notification, iOS passes the notification to app in launchOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Handle push notifications
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]

        if let notification = notificationOption as? [String: AnyObject],
           let aps = notification["aps"] as? [String: AnyObject] {
            print("Remote Push Notification did finish launching:", aps)
        }

        // Remote notification request permission
        registerForPushNotifications()
        return true
    }

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                //To add options in the push notification. This will add one View button when you tap and hold on the push notification
                let viewAction = UNNotificationAction(
                    identifier: Identifiers.viewAction,
                    title: "View",
                    options: [.foreground])
                let newsCategory = UNNotificationCategory(
                    identifier: Identifiers.newsCategory,
                    actions: [viewAction],
                    intentIdentifiers: [],
                    options: []
                )
                UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
                self?.getNotificationSettings()
          }
    }

    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                //This generates the device token if succeed
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // Called when APNs has successfully registered your device
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        // Forward the token to your provider, using a custom method.
    }

    // Called when registration for remote notifications fails
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
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

/* Example Payload
 {
     "aps" : {
        "alert" : {
             "title" : "Check out our new special!",
             "body" : "Avocado Bacon Burger on sale"
         },
         "sound" : "default",
         "badge" : 1,
    },
     "special" : "avocado_bacon_burger",
     "price" : "9.99"
 }
 */

//Handle background/foreground push notification, this is when app is running
extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        print("Remote Push Notification did receive:", aps)
        //Make changes in the app
        completionHandler(.noData)
    }
}
