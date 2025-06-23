//
//  CountDownHome.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/06/25.
//

import SwiftUI

struct CountDownHome: View {
    
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var search = ""

    var body: some View {
        VStack(spacing: 0) {
            getHeaderImage()
                .padding(.bottom,24)
            Text("Your Events")
                .font(.system(size: 24, weight: .bold, design: .default))
                .alignLeft()
                .padding(.leading)
                .padding(.bottom,12)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $search)
            }
            .padding(.all,10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
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
