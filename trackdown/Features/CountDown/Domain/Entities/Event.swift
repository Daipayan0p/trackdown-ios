import Foundation
import SwiftData
import SwiftUI

@Model
class Event {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String
    var colorData: Data
    @Attribute var date: Date
    @Attribute var time: Date
    
    init(title: String, note: String = "", color: Color = .blue, date: Date = Date(), time: Date = Date(), reminder: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.colorData = Self.colorToData(color)
        self.date = date
        self.time = time
    }
    
    // Computed property to get Color from stored Data
    var color: Color {
        get {
            Self.dataToColor(colorData)
        }
        set {
            colorData = Self.colorToData(newValue)
        }
    }
    
    // Helper methods to convert Color to/from Data for SwiftData storage
    private static func colorToData(_ color: Color) -> Data {
         let uiColor = UIColor(color)
         return try! NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: true)
     }
     
     private static func dataToColor(_ data: Data) -> Color {
         guard let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
             return .blue // Default color if conversion fails
         }
         return Color(uiColor)
     }
}

extension Event {
    func daysLeft() -> Int? {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfEvent = Calendar.current.startOfDay(for: date)
        
        let diff = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfEvent)
        return diff.day
    }
    
    private func combineDateAndTime() -> Date {
           let calendar = Calendar.current
           let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
           let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
           
           var combinedComponents = DateComponents()
           combinedComponents.year = dateComponents.year
           combinedComponents.month = dateComponents.month
           combinedComponents.day = dateComponents.day
           combinedComponents.hour = timeComponents.hour
           combinedComponents.minute = timeComponents.minute
           combinedComponents.second = timeComponents.second
           
           return calendar.date(from: combinedComponents) ?? date
       }
       
       // Property to get the combined date and time
       var dateTime: Date {
           return combineDateAndTime()
       }
       
       // Check if event is expired
       var isExpired: Bool {
           return dateTime <= Date()
       }
       
       // Get time remaining in a readable format
       var timeRemaining: String {
           let now = Date()
           let eventDateTime = combineDateAndTime()
           
           if eventDateTime <= now {
               return "Expired"
           }
           
           let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: eventDateTime)
           
           if let days = components.day, days > 0 {
               return "\(days) day\(days == 1 ? "" : "s")"
           } else if let hours = components.hour, hours > 0 {
               return "\(hours) hour\(hours == 1 ? "" : "s")"
           } else if let minutes = components.minute, minutes > 0 {
               return "\(minutes) minute\(minutes == 1 ? "" : "s")"
           } else {
               return "Less than a minute"
           }
       }
}
