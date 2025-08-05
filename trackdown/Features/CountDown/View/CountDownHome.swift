//
//  CountDownHome.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/06/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct CountDownHome: View {
    
    // Replace @State with @Query for SwiftData - sorted by date and time
    @Query(sort: [SortDescriptor(\Event.date), SortDescriptor(\Event.time)]) private var events: [Event]
    @Environment(\.modelContext) private var context
    
    @State var showBottomSheet: Bool = false
    @State var selectedEvent: Event? = nil
    
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var search = ""
    @Environment(\.colorScheme) var colorScheme
    
    // Computed property to filter events based on search and remove expired events
    var filteredEvents: [Event] {
        let now = Date()
        // Filter out expired events first
        let activeEvents = events.filter { event in
            let eventDateTime = combineDateAndTime(date: event.date, time: event.time)
            return eventDateTime > now
        }
        
        // Then apply search filter
        if search.isEmpty {
            return activeEvents
        } else {
            return activeEvents.filter { event in
                event.title.localizedCaseInsensitiveContains(search) ||
                event.note.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                getHeaderImage()
                    .padding(.bottom,24)
                HStack {
                    Text("Your Events")
                        .font(.system(size: 24, weight: .bold, design: .default))
                    
                    
                    Spacer()
                    
                    Button(action: {
                        selectedEvent = nil 
                        showBottomSheet.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .padding(.horizontal,6)
                    }
                    
                    Button(action: {
                        print("Create Event tapped")
                    }) {
                        Image(systemName: "power.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.red)
                            .onTapGesture {
                                authVM.signOut()
                            }
                    }
                    
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $search)
                }
                .padding(.all,10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if !filteredEvents.isEmpty{
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredEvents) { event in
                                SwipeableEventCardView(event: event) {
                                    deleteEvent(event)
                                }
                                .onTapGesture(count:2) {
                                    selectedEvent = event
                                    showBottomSheet = true
                                }
                            }
                        }
                        .padding(.vertical,14)
                    }
                }
                
                // Show message if no events
                if filteredEvents.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text(search.isEmpty ? "No events yet" : "No events found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        if search.isEmpty {
                            Text("Tap the + button to create your first event")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Spacer()
                    }
                    .padding(.top, 50)
                }
            }
            if showBottomSheet {
                Color.black
                    .opacity(0.5) // Adjustable darkness
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeInOut, value: showBottomSheet)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .sheet(isPresented: $showBottomSheet) {
            AddEventBottomSheetView(eventToEdit: selectedEvent)
                .presentationDetents([.fraction(0.8),.fraction(0.97)])
        }
        .onAppear {
            if events.isEmpty {
                addSampleData()
            }
            // Clean up expired events
            cleanupExpiredEvents()
            WidgetCenter.shared.reloadTimelines(ofKind: "trackdown_widget")
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            // Clean up expired events every minute
            cleanupExpiredEvents()
        }
    }
    
    // Helper function to combine date and time
    private func combineDateAndTime(date: Date, time: Date) -> Date {
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
    
    // Function to clean up expired events
    private func cleanupExpiredEvents() {
        let now = Date()
        _ = Calendar.current
        
        let expiredEvents = events.filter { event in
            let eventDateTime = combineDateAndTime(date: event.date, time: event.time)
            return eventDateTime <= now
        }
        
        for event in expiredEvents {
            context.delete(event)
        }
        
        if !expiredEvents.isEmpty {
            try? context.save()
        }
    }
    
    // Function to delete an event
    private func deleteEvent(_ event: Event) {
        context.delete(event)
        try? context.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "trackdown_widget")
    }
    
    // Function to add sample data (optional - remove in production)
    private func addSampleData() {
        let sampleEvents = [
            Event(title: "Birthday Party", note: "John's birthday celebration", color: .customLightBlue, date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
            Event(title: "Project Deadline", note: "Submit final report", color: .customLightCyan, date: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()),
            Event(title: "Vacation", note: "Trip to the mountains", color: .customLightPurple, date: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date())
        ]
        
        for event in sampleEvents {
            context.insert(event)
        }
        
        try? context.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "trackdown_widget")
    }
    
    @ViewBuilder
    func getHeaderImage() -> some View {
        Image(colorScheme == .light ? "headerLight" : "headerDark")
            .resizable()
            .scaledToFill()
            .frame(height: 150,alignment: colorScheme == .light ? .center : .bottom)
            .clipped()
    }
    
}

#Preview {
    CountDownHome()
        .modelContainer(for: Event.self, inMemory: true)
}
