//
//  Buttons.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import SwiftUI

struct AuthButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isEnabled ? Color.customButtonBlue : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .padding(.vertical)
    }
}

struct SocialLoginButton: View {
    let imageName: String
    let size: CGFloat
    let action: () -> Void
    
    init(imageName: String, size: CGFloat = 40, action: @escaping () -> Void) {
        self.imageName = imageName
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .frame(width: size, height: size)
        }
    }
}
