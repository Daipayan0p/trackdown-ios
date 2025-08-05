//
//  Date+Extension.swift
//  trackdown
//
//  Created by Daipayan Neogi on 17/07/25.
//

import Foundation

extension Date {
    /// Formats date as "July 1, 2025"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    /// Formats date as "Jul 1, 2025" (shorter month name)
    var formattedDateShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    var formattedDateShortOnly: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // 👈 short year
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    /// Formats time as "2:30 PM"
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    /// Formats date and time as "July 1, 2025 at 2:30 PM"
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    /// Returns relative date string like "Today", "Tomorrow", "Yesterday", or formatted date
    var relativeFormattedDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            // Check if it's within this week
            let daysFromNow = calendar.dateComponents([.day], from: now, to: self).day ?? 0
            if abs(daysFromNow) <= 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE" // Day of week
                return formatter.string(from: self)
            } else {
                return formattedDate
            }
        }
    }
    
    /// Returns days difference from today (positive for future, negative for past)
    func daysFromToday() -> Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: self)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return components.day ?? 0
    }
    
    /// Returns true if the date is in the future
    var isFuture: Bool {
        return self > Date()
    }
    
    /// Returns true if the date is in the past
    var isPast: Bool {
        return self < Date()
    }
    
    /// Returns true if the date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
}
