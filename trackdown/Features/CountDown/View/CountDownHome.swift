//
//  CountDownHome.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/06/25.
//

import SwiftUI

struct CountDownHome: View {
    
    @State private var events: [Event] = [
        Event(id: UUID(), title: "Event 1", date: "July 1, 2025"),
        Event(id: UUID(), title: "Event 2", date: "July 10, 2025"),
        Event(id: UUID(), title: "Event 3", date: "August 5, 2025")
    ]


    @EnvironmentObject private var authVM: AuthViewModel
    @State private var search = ""
    
    var body: some View {
        VStack(spacing: 0) {
            getHeaderImage()
                .padding(.bottom,24)
            HStack {
                Text("Your Events")
                    .font(.system(size: 24, weight: .bold, design: .default))

                Spacer()
                
                Button(action: {
                    print("Create Event tapped")
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.gray)
                        .onTapGesture {
                            authVM.signOut()
                        }
                }

                Button(action: {
                    print("Create Event tapped")
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
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
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(events) { event in
                        SwipeableEventCardView(event: event){
                            events.removeAll { $0.id == event.id }
                        }
                    }
                }
                .padding(.vertical,14)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    
    @ViewBuilder
    func getHeaderImage() -> some View {
        AsyncImage(url: URL(string: "https://img.freepik.com/free-vector/hand-drawn-abstract-doodle-background_23-2149323522.jpg?semt=ais_hybrid&w=740")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(height: 150)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
            case .failure:
                Image(systemName: "xmark.octagon")
                    .frame(height: 150)
            @unknown default:
                EmptyView()
                    .frame(height: 150)
            }
        }
    }
}


#Preview {
    CountDownHome()
}
