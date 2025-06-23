//
//  EventCardView.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/05/25.
//

import SwiftUI

struct EventCardView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("Hello")
                Spacer()
            }
            .padding()
            .frame(
                width: geometry.size.width,
                height: geometry.size.height * 0.1 // 10% of the screen height
            )
            .background(Color.customLightBlue)
            .cornerRadius(12)
        }
    }
    
}

#Preview {
    EventCardView()
        .padding()
}
