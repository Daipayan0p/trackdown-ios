//
//  AuthTextField.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .inputFieldStyle()
    }
}

struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .inputFieldStyle()
            .textContentType(.password)
    }
}

