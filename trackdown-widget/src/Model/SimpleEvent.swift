//
//  SimpleEvent.swift
//  trackdown-widgetExtension
//
//  Created by Daipayan Neogi on 22/07/25.
//

import Foundation
import UIKit

enum TimeUnit: String, Codable {
    case days
    case day
    case hour
}


struct SimpleEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let note: String
    let date: Date
    let time: Date
    let timeRemainingValue: Int?
    let timeUnit: TimeUnit?
    let isExpired: Bool
    let colorHex: String
}

extension Event {
    func toSimpleEvent() -> SimpleEvent {
        let calendar = Calendar.current
        let dateTime = calendar.date(bySettingHour: calendar.component(.hour, from: time),
                                     minute: calendar.component(.minute, from: time),
                                     second: 0, of: date) ?? date

        let now = Date()
        let isExpired = dateTime <= now

        var timeRemainingValue: Int? = nil
        var timeUnit: TimeUnit? = nil

        if !isExpired {
            let components = calendar.dateComponents([.day, .hour], from: now, to: dateTime)
            if let days = components.day, days > 1 {
                timeRemainingValue = days
                timeUnit = .days
            }
            else if let day = components.day, day == 1 {
                timeRemainingValue = day
                timeUnit = .day
            }
            else if let hours = components.hour, hours > 0 {
                timeRemainingValue = hours
                timeUnit = .hour
            }
        }

        let hex = UIColor(color).toHexString()

        return SimpleEvent(
            id: self.id,
            title: self.title,
            note: self.note,
            date: self.date,
            time: self.time,
            timeRemainingValue: timeRemainingValue,
            timeUnit: timeUnit,
            isExpired: isExpired,
            colorHex: hex
        )
    }
}


