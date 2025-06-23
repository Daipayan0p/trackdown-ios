//
//  View+Extension.swift
//  trackdown
//
//  Created by Daipayan Neogi on 16/06/25.
//

import Foundation
import SwiftUI

extension View {
    func inputFieldStyle() -> some View {
        self.modifier(InputFieldModifier())
    }
}


// Alignment Extension
extension View {
    func alignLeft() -> some View {
        HStack {
            self
            Spacer()
        }
    }
}
