//
//  EventCardView.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/05/25.
//

import SwiftUI

struct EventCardView: View {
    let event: Event
    var body: some View {
        HStack {
            VStack {
                if let days = event.daysLeft() {
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
        .background(event.color)
        .cornerRadius(12)
    }
    
}

struct SwipeableEventCardView: View {
    let event: Event
    var onDelete: () -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 60,height: 58)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            
            // Foreground card
            EventCardView(event: event)
                .offset(x: offsetX + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            if value.translation.width < 0 {
                                state = value.translation.width
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < -80 {
                                withAnimation {
                                    offsetX = -80
                                }
                            } else {
                                withAnimation {
                                    offsetX = 0
                                }
                            }
                        }
                )
        }
        .padding(.horizontal)
    }
}
