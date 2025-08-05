//
//  AddEventBottomSheet.swift
//  trackdown
//
//  Created by Daipayan Neogi on 05/07/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddEventBottomSheetView: View {
    @Environment(\.modelContext) private var context
    @State private var event:String = ""
    @State private var note: String = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedColor : Color = .customLightBlue
    @Environment(\.dismiss) var dismiss
    @State private var isReminder: Bool = false
    @State private var reminder = Date()
    @State private var showLessThanOneHourAlert = false
    @State private var addToCalender = false
    
    
    let eventToEdit: Event?
    
    func combine(date: Date, time: Date) -> Date? {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time)
        
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        
        return Calendar.current.date(from: dateComponents)
    }
    
    private var isEditing: Bool {
        eventToEdit != nil
    }
    
    init(eventToEdit: Event? = nil) {
        self.eventToEdit = eventToEdit
    }
    
    private func saveEvent(){
        if let eventToEdit = eventToEdit {
            // Update existing event
            eventToEdit.title = event
            eventToEdit.note = note
            eventToEdit.color = selectedColor
            eventToEdit.date = selectedDate
            eventToEdit.time = selectedTime
        } else {
            // Create new event
            let newEvent = Event(
                title: event,
                note: note,
                color: selectedColor,
                date: selectedDate,
                time: selectedTime,
            )
            context.insert(newEvent)
        }
        
        do {
            try context.save()
            
            // Add to Apple Calendar
            if addToCalender {
                addEventToAppleCalendar(title: event, note: note, date: selectedDate, time: selectedTime) { success, error in
                    if success {
                        print("✅ Event added to calendar")
                    } else {
                        print("❌ Failed to add event: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            
            // Schedule Notification
            if isReminder{
                scheduleNotification(at: reminder, title: "Reminder", body: "Don't forget your event \(event)")
            }
            dismiss()
            WidgetCenter.shared.reloadTimelines(ofKind: "trackdown_widget")

        } catch {
            print("❌ Failed to save event: \(error)")
        }
    }
    
    
    var body: some View {
        VStack{
            getHeader()
                .padding(.horizontal,24)
                .padding(.top,28)
            
            List{
                createEventSection()
                chooseColorSection()
                chooseDateSection()
                if !isEditing{
                    reminderSection()
                }
            }
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .padding(.top, -25)
            
            Spacer()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .onAppear {
            // Populate fields if editing an existing event
            if let eventToEdit = eventToEdit {
                event = eventToEdit.title
                note = eventToEdit.note
                selectedColor = eventToEdit.color
                selectedDate = eventToEdit.date
                selectedTime = eventToEdit.time
            }
        }
        .alert("Event is less than 1 hour from now can't be added", isPresented: $showLessThanOneHourAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    func reminderSection() -> some View {
        Section(header: Text("Reminder")) {
            HStack {
                Image(systemName: "calendar.badge.plus")
                Text("Add to Calendar ")
                Spacer()
                Toggle("", isOn: $addToCalender)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            HStack {
                Image(systemName: "bell.fill")
                Text("Reminder")
                Spacer()
                Toggle("", isOn: $isReminder)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            
            if isReminder {
                HStack {
                    Image(systemName: "calendar")
                    Text("Date")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $reminder,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                
                HStack {
                    Image(systemName: "clock")
                    Text("Time")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $reminder,
                        in: Date()...,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }
        }
        .listRowBackground(Color(.systemGray6))
    }
    
    @ViewBuilder
    func chooseDateSection() -> some View {
        Section(
            header: Text("Choose Date & Time")
                .padding(.leading, -16)
        ){
            HStack{
                Image(systemName: "calendar")
                Text("Date")
                Spacer()
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .labelsHidden()
            }
            HStack{
                Image(systemName: "clock")
                Text("Time")
                Spacer()
                DatePicker("", selection: $selectedTime,in: Date()..., displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
        }
        .listRowBackground(Color(.systemGray6))
        
    }
    
    @ViewBuilder
    func chooseColorSection() -> some View {
        Section(
            header:Text("Choose Color")
                .padding(.leading, -16)
        ){
            HStack{
                Text("Color")
                Spacer()
                buildColorPicker(color: .customLightBlue)
                buildColorPicker(color: .customLightCyan)
                buildColorPicker(color: .customLightPurple)
            }
        }
        .listRowBackground(Color(.systemGray6))
        
    }
    
    @ViewBuilder
    func buildColorPicker(color:Color) -> some View {
        ZStack{
            if(selectedColor == color){
                Circle()
                    .frame(width: 34, height: 34)
            }
            
            
            Circle()
                .fill(color)
                .frame(width: selectedColor == color ? 30: 32, height: selectedColor == color ? 30: 32)
        }
        .onTapGesture {
            withAnimation{
                selectedColor = color
            }
        }
        
    }
    
    @ViewBuilder
    func createEventSection() -> some View {
        Section{
            TextField("New Event", text: $event)
            TextField("Note", text: $note)
        }
        .listRowBackground(Color(.systemGray6))
        
    }
    
    @ViewBuilder
    func getHeader() -> some View {
        HStack{
            Button{
                dismiss()
            }label: {
                Text("Cancel")
            }
            Spacer()
            
            Text(isEditing ? "Edit Event" : "Create Event")
                .font(.system(size: 21, weight: .semibold))
            Spacer()
            Button{
                if let eventDateTime = combine(date: selectedDate, time: selectedTime) {
                    if eventDateTime < Date().addingTimeInterval(3600) {
                        showLessThanOneHourAlert = true
                        return
                    }
                }
                saveEvent()
            }label: {
                Text("Done")
            }
        }
    }
    
    
    
}

#Preview {
    AddEventBottomSheetView()
}
