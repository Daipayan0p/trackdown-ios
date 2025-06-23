//
//  SignUpData.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation

struct SignUpData {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
    
    var isValid: Bool {
        return !name.isEmpty &&
               !email.isEmpty &&
               !password.isEmpty &&
               password == confirmPassword &&
               password.count >= 6 &&
               email.contains("@")
    }
}
