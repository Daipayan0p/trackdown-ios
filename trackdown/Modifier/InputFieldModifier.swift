//
//  InputFieldModifier.swift
//  trackdown
//
//  Created by Daipayan Neogi on 16/06/25.
//

import Foundation
import SwiftUI

struct InputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color.customTextAreaLightGrey)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)

    }
}
