//
//  ReminderUtils.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/07/25.
//

import Foundation
import EventKit
import UserNotifications

func addEventToAppleCalendar(title: String, note: String, date: Date, time: Date, completion: @escaping (Bool, Error?) -> Void) {
    let eventStore = EKEventStore()
    
    let requestAccess: (@escaping (Bool, Error?) -> Void) -> Void = { handler in
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: handler)
        } else {
            eventStore.requestAccess(to: .event, completion: handler)
        }
    }

    requestAccess { granted, error in
        if let error = error {
            completion(false, error)
            return
        }

        if granted {
            let calendar = eventStore.defaultCalendarForNewEvents
            let event = EKEvent(eventStore: eventStore)

            // Combine date and time
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)

            var combined = DateComponents()
            combined.year = dateComponents.year
            combined.month = dateComponents.month
            combined.day = dateComponents.day
            combined.hour = timeComponents.hour
            combined.minute = timeComponents.minute

            guard let startDate = Calendar.current.date(from: combined) else {
                completion(false, NSError(domain: "Invalid date", code: 0, userInfo: nil))
                return
            }

            event.title = title
            event.notes = note
            event.startDate = startDate
            event.endDate = startDate.addingTimeInterval(60 * 60) // 1 hour
            event.calendar = calendar

            do {
                try eventStore.save(event, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        } else {
            completion(false, NSError(domain: "Access denied", code: 1, userInfo: nil))
        }
    }
}


func scheduleNotification(at date: Date, title: String, body: String = "") {
    let center = UNUserNotificationCenter.current()
    
    // Request notification permission
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted && error == nil {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            // Create trigger
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let identifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Notification scheduling error: \(error.localizedDescription)")
                } else {
                    print("✅ Notification scheduled at \(date)")
                }
            }
        } else {
            print("❌ Permission not granted: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
