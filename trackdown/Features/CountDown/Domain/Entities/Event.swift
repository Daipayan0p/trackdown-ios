//
//  Event.swift
//  trackdown
//
//  Created by Daipayan Neogi on 01/07/25.
//

import Foundation
struct Event: Identifiable {
    let id: UUID
    let title: String
    let date: String
}


extension Event {
    func daysLeft() -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy" // Matches "July 10, 2025"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let eventDate = formatter.date(from: date) else {
            return nil
        }

        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfEvent = Calendar.current.startOfDay(for: eventDate)

        let diff = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfEvent)
        return diff.day
    }
}
