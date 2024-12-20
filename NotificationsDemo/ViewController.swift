//
//  ViewController.swift
//  NotificationsDemo
//
//  Created by Mayur Bendale on 15/09/24.
//

import UIKit

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
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleLocalNotificationWithCustomAction() {
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: [.foreground])
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: [.foreground])
        // Define the notification type
        let meetingInviteCategory =
              UNNotificationCategory(identifier: "MEETING_INVITATION",
              actions: [acceptAction, declineAction],
              intentIdentifiers: [],
              hiddenPreviewsBodyPlaceholder: "",
              options: .customDismissAction)
        // Register the notification type.
        UNUserNotificationCenter.current().setNotificationCategories([meetingInviteCategory])

        let content = UNMutableNotificationContent()
        content.title = "Weekly Staff Meeting"
        content.body = "Every Tuesday at 2pm"
        content.userInfo = ["MEETING_ID" : "M1234",
                            "USER_ID" : "U1234" ]
        content.categoryIdentifier = "MEETING_INVITATION"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }
}
