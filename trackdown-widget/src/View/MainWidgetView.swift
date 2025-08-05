//
//  MainWidgetView.swift
//  trackdown-widgetExtension
//
//  Created by Daipayan Neogi on 23/07/25.
//

import SwiftUI
import WidgetKit

struct MainWidgetView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Group {
            if family == .systemMedium {
                mediumView
            } else if family == .systemLarge {
                largeView
            } else {
                EmptyView() // fallback or leave empty
            }
        }
    }
    
    var largeView : some View {
        VStack{
            ForEach(entry.event.prefix(5)){ event in
                EventCardView(event: event)
            }
            Spacer()
        }
    }
    
    var mediumView : some View {
        VStack {
            HStack{
                upcomingEventCardView(event: entry.event[0])
                Divider()
                    .frame(height: 160)
                    .frame(width: 1) // Thickness
                    .background(.black)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(entry.event.dropFirst().prefix(3).enumerated()), id: \.element.id) { index, event in
                        eventCardView(event: event)
                        
                        if index < 2 { // Add divider after the first and second items
                            Divider()
                                .frame(height: 2)
                                .background(.gray)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
            }
        }
    }
    
    
    @ViewBuilder func upcomingEventCardView(event:SimpleEvent) -> some View{
        VStack(alignment:.leading){
            Text(event.title)
                .font(.system(size: 18, weight: .heavy))
            Text("\(event.timeRemainingValue ?? 0)")
                .font(.system(size: 42, weight: .black))
            
            Text(event.timeUnit?.rawValue ?? "--")
                .font(.system(size: 14, weight: .bold))
            Text(event.date.formattedDateShortOnly)
                .font(.system(size: 14, weight: .bold))
            
        }
        .frame(width: 90)
    }
    
    @ViewBuilder
    private func eventCardView(event:SimpleEvent) -> some View{
        HStack(){
            VStack(alignment:.leading){
                Text(event.title)
                    .font(.system(size: 14, weight: .heavy))
                Text(event.date.formattedDateShortOnly)
                    .font(.system(size: 14, weight: .medium))
            }
            Spacer()
            VStack{
                Text("\(event.timeRemainingValue ?? 0)")
                    .font(.system(size: 16, weight: .heavy))
                Text(event.timeUnit?.rawValue ?? "--")
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }
}

#Preview(as: .systemLarge) {
    trackdown_widget()
} timeline: {
    SimpleEntry(date: .now, event: [
        Event(title: "Birthday Party ", note: "Submit final report", color: .red, date: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()).toSimpleEvent(),
        Event(title: "Party", note: "John's birthday celebration", color: .blue, date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()).toSimpleEvent(),
        Event(title: "Vacation", note: "Trip to the mountains", color: .red, date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()).toSimpleEvent(),
        Event(title: "Vacation", note: "Trip to the mountains", color: .red, date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()).toSimpleEvent(),
        Event(title: "Vacation", note: "Trip to the mountains", color: .red, date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()).toSimpleEvent()
    ])
}

struct EventCardView: View {
    let event: SimpleEvent
    var body: some View {
        HStack {
            VStack {
                if let days = event.timeRemainingValue {
                    Text("\(days)")
                        .font(.system(size: 16, weight: .bold))
                    Text("Days")
                        .font(.system(size: 12))
                } else {
                    Text("--")
                        .font(.system(size: 16, weight: .bold))
                    Text("Invalid")
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal)
            Text(event.title)
                .font(Font.system(size: 16, weight:.semibold))
            
            Spacer()
            Text(event.date.formattedDateShort)
                .font(Font.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(height: 60)
        .background(Color(hex: event.colorHex))
        .cornerRadius(12)
    }
    
}
