import UIKit

//Local Notifications
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAutherization()
    }

    // MARK: Local Notification
    private func requestAutherization() {
        let center = UNUserNotificationCenter.current()
        // Obtain the notification settings.
        center.getNotificationSettings { settings in
            // Verify the authorization status.
            guard settings.authorizationStatus != .authorized else {
                self.scheduleNotification()
                return
            }

            // Request permission to display notifications
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    self.scheduleNotification()
                } else if let error = error {
                    print("Permission not granted: \(error.localizedDescription)")
                }
            }
        }
    }

    private func scheduleNotification() {
//        scheduleLocalNotification()
        scheduleLocalNotificationWithCustomAction()
    }

    private func scheduleLocalNotification() {
        let center = UNUserNotificationCenter.current()
        //Remove pending notifications
        center.removeAllPendingNotificationRequests()

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Local Notification"
        content.body = "This is a local notification."
        content.sound = .default
        content.interruptionLevel = .active

        // A trigger condition that causes a notification the system delivers at a specific date and time
//        var dateComponent = DateComponents(calendar: Calendar.current)
//        dateComponent.hour = 4
//        dateComponent.minute = 0
//        dateComponent.second = 0
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)

        //A trigger condition that causes the system to deliver a notification when the user’s device enters or exits a geographic region you specify
//        let center = CLLocationCoordinate2D(latitude: 37.335400, longitude: -122.009201)
//        let region = CLCircularRegion(center: center, radius: 2000.0, identifier: "Headquarters")
//        region.notifyOnEntry = true
//        region.notifyOnExit = false
//        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)

        // Create the trigger (in 5 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Schedule the notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleLocalNotificationWithCustomAction() {
        let center = UNUserNotificationCenter.current()
        // Set the notification center delegate
        center.delegate = self

        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: [.foreground])
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: [.foreground])
        // Define the notification type
        let identifier = "MEETING_INVITATION"
        let meetingInviteCategory = UNNotificationCategory(identifier: identifier,
                                                           actions: [acceptAction, declineAction],
                                                           intentIdentifiers: [],
                                                           hiddenPreviewsBodyPlaceholder: "")
        // Register the notification type.
        center.setNotificationCategories([meetingInviteCategory])

        let content = UNMutableNotificationContent()
        content.title = "Weekly Staff Meeting"
        content.body = "Every Tuesday at 2pm"
        content.userInfo = ["MEETING_ID" : "M1234",
                            "USER_ID" : "U1234" ]
        content.categoryIdentifier = identifier
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    // Handle local notifications when the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification with sound, badge, and alert
        completionHandler([.banner, .sound, .badge])
    }

    // Handle user's response to the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Handle notification response
        print("Notification user info: \(userInfo)")
        // Get the meeting ID from the original notification.
        if let meetingID = userInfo["MEETING_ID"] as? String,
           let userID = userInfo["USER_ID"] as? String {
            print("Meeting ID: \(meetingID), User ID: \(userID)")
        }

        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("Accept action")
        case "DECLINE_ACTION":
            print("Decline action")
        default:
            break
        }

        // Always call the completion handler when done.
        completionHandler()
    }
}
