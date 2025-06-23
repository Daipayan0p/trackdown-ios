//
//  AuthRepositoryProtocol.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation

protocol AuthRepositoryProtocol {
    func signIn(credentials: AuthCredentials) async throws -> User
    func signUp(signUpData: SignUpData) async throws 
    func signOut() async throws
    func getCurrentUser() async -> User?
    func handleDeepLink(_ url: URL) async throws
    func observeAuthState() -> AsyncStream<Bool>
}

protocol SignInUseCaseProtocol {
    func execute(credentials: AuthCredentials) async throws -> User
}

protocol SignUpUseCaseProtocol {
    func execute(signUpData: SignUpData) async throws
}

protocol SignOutUseCaseProtocol {
    func execute() async throws
}

protocol ObserveAuthUseCaseProtocol {
    func execute() -> AsyncStream<Bool>
}
