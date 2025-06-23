//
//  AuthViewModel.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation

import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let signInUseCase: SignInUseCaseProtocol
    private let signUpUseCase: SignUpUseCaseProtocol
    private let signOutUseCase: SignOutUseCaseProtocol
    private let observeAuthUseCase: ObserveAuthUseCaseProtocol
    private let repository: AuthRepositoryProtocol
    
    init(
        signInUseCase: SignInUseCaseProtocol,
        signUpUseCase: SignUpUseCaseProtocol,
        signOutUseCase: SignOutUseCaseProtocol,
        observeAuthUseCase: ObserveAuthUseCaseProtocol,
        repository: AuthRepositoryProtocol
    ) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
        self.observeAuthUseCase = observeAuthUseCase
        self.repository = repository
        
        startObservingAuthState()
    }
    
    func signIn(email: String, password: String) {
        Task {
            await performAuthAction { [self] in
                let credentials = AuthCredentials(email: email, password: password)
                let user = try await self.signInUseCase.execute(credentials: credentials)
                currentUser = user
            }
        }
    }
    
    func signUp(signUpData: SignUpData) {
        Task {
            await performAuthAction { [self] in
                try await signUpUseCase.execute(signUpData: signUpData)
            }
        }
    }
    
    func signOut() {
        Task {
            await performAuthAction { [self] in
                try await signOutUseCase.execute()
                currentUser = nil
            }
        }
    }
    
    func handleDeepLink(_ url: URL) {
        Task {
            await performAuthAction { [self] in
                try await repository.handleDeepLink(url)
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    private func startObservingAuthState() {
        Task {
            for await isAuth in observeAuthUseCase.execute() {
                isAuthenticated = isAuth
                if !isAuth {
                    currentUser = nil
                }
            }
        }
    }
    
    private func performAuthAction(_ action: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await action()
        } catch let authError as AuthError {
            errorMessage = authError.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
}
