//
//  trackdown_widget.swift
//  trackdown-widget
//
//  Created by Daipayan Neogi on 22/07/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: @preconcurrency TimelineProvider {
    @MainActor func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), event: getEvent())
    }
    
    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), event: getEvent())
        completion(entry)
    }
    
    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        
        let timeline = Timeline(entries: [SimpleEntry(date: .now, event: getEvent())], policy: .after(.now.advanced(by: 60*60)))
        completion(timeline)
    }
    @MainActor
    private func getEvent() -> [SimpleEvent] {
        guard let modelContainer = try? ModelContainer(for: Event.self) else {
            return []
        }
        
        var descriptor = FetchDescriptor<Event>()
        descriptor.sortBy = [SortDescriptor(\.date),SortDescriptor(\.time)]
        let events = try? modelContainer.mainContext.fetch(descriptor)
        return events?.map { $0.toSimpleEvent() } ?? []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let event: [SimpleEvent]
}

struct trackdown_widgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            HStack{
                upcomingEventCardView(event: entry.event[0])
                Divider()
                    .frame(height: 160)
                    .frame(width: 1) // Thickness
                    .background(.black)
                VStack(alignment: .leading,spacing: 10){
                    ForEach(entry.event.dropFirst().prefix(3)){ event in
                        eventCardView(event: event)
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
            Text("14")
                .font(.system(size: 42, weight: .black))
            
            Text("days")
                .font(.system(size: 14, weight: .bold))
            Text("11/05/25")
                .font(.system(size: 14, weight: .bold))
            
        }
        .frame(width: 100)
    }
    
    @ViewBuilder
    private func eventCardView(event:SimpleEvent) -> some View{
        HStack(){
            VStack(alignment:.leading){
                Text(event.title)
                    .font(.system(size: 14, weight: .heavy))
                if(event.date.isToday){
                    Text(event.date.relativeFormattedDate)
                        .font(.system(size: 14, weight: .medium))
                }else{
                    Text(event.date.formattedDateShort)
                        .font(.system(size: 14, weight: .medium))
                }
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

struct trackdown_widget: Widget {
    let kind: String = "trackdown_widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                trackdown_widgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                trackdown_widgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}


