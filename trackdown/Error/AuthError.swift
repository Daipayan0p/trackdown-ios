//
//  AuthError.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidInput
    case invalidCredentials
    case networkError
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Please fill in all fields correctly"
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection error"
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "Email already exists"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .unknown(let message):
            return message
        }
    }
}
