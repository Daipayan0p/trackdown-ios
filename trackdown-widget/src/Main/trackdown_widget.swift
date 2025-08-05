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

/// Main view that is showed
struct trackdown_widgetEntryView : View {
    var entry: SimpleEntry
    
    var body: some View {
        MainWidgetView(entry: entry)
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
        .supportedFamilies([.systemMedium,.systemLarge])
    }
}

