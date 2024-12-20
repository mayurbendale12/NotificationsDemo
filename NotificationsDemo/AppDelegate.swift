//
//  AppDelegate.swift
//  NotificationsDemo
//
//  Created by Mayur Bendale on 15/09/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Remote notification request permission
        UIApplication.shared.registerForRemoteNotifications()
        // Set the notification center delegate
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // Called when APNs has successfully registered your device
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        // Forward the token to your provider, using a custom method.
        forwardTokenToServer(tokenString: token)
    }

    // Called when registration for remote notifications fails
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    private func forwardTokenToServer(tokenString: String) {
        print("Token: \(tokenString)")
        let queryItems = [URLQueryItem(name: "deviceToken", value: tokenString)]
        var urlComps = URLComponents(string: "www.example.com/register")!
        urlComps.queryItems = queryItems
        guard let url = urlComps.url else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                // Handle the error
                return
            }
            guard response != nil else {
                // Handle empty response
                return
            }
            guard data != nil else {
                // Handle empty data
                return
            }

            // Handle data
        }

        task.resume()
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle push notifications when the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification with sound, badge, and alert
        completionHandler([.banner, .sound])
    }

    // Handle user's response to the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Handle notification response
        print("Notification user info: \(userInfo)")
        // Get the meeting ID from the original notification.
        let meetingID = userInfo["MEETING_ID"] as! String
        let userID = userInfo["USER_ID"] as! String

        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            break
        case "DECLINE_ACTION":
            break
        default:
            break
        }

        // Always call the completion handler when done.
        completionHandler()
    }
}

//Handle background notification
extension AppDelegate {
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let url = URL(string: "www.example.com/todays-menu") else {
            completionHandler(.failed)
            return
        }

        let session = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Error fetching menu from server! \(error.localizedDescription)")
                completionHandler(.failed)
                return
            }
            guard response != nil else {
                print("No response found fetching menu from the server")
                completionHandler(.noData)
                return
            }
            guard let data = data else {
                print("No data found fetching menu from the server")
                completionHandler(.noData)
                return
            }

            self.updateMenu(withData: data)
            completionHandler(.newData)
        }

        session.resume()
    }

    private func updateMenu(withData data: Data) {
        // Use the data fetched to update the content of the application in the background.
    }
}
