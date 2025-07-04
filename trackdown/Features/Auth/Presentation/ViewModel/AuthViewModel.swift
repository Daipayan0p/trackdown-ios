//
//  AuthViewModel.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation
import GoogleSignIn
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
    private let signInWithGoogleUseCase: SignInWithGoogleProtocol
    
    init(
        signInUseCase: SignInUseCaseProtocol,
        signUpUseCase: SignUpUseCaseProtocol,
        signOutUseCase: SignOutUseCaseProtocol,
        observeAuthUseCase: ObserveAuthUseCaseProtocol,
        repository: AuthRepositoryProtocol,
        signInWithGoogleUseCase: SignInWithGoogleProtocol
    ) {
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
        self.observeAuthUseCase = observeAuthUseCase
        self.repository = repository
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        
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
    
    func signInWithGoogle(idToken: String) {
        Task {
            await performAuthAction { [self] in
                let user = try await signInWithGoogleUseCase.execute(idToken: idToken)
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
    
    // Updated Google Sign In method that properly integrates with your existing flow
    func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                     let window = windowScene.windows.first,
                     let presentingViewController = window.rootViewController else {
                   errorMessage = "Unable to get presenting view controller"
                   return
               }
        isLoading = true
        errorMessage = nil
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let signInResult = signInResult else {
                    self.errorMessage = "Failed to get sign in result"
                    self.isLoading = false
                    return
                }
                
                signInResult.user.refreshTokensIfNeeded { user, error in
                    Task { @MainActor in
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            self.isLoading = false
                            return
                        }
                        
                        guard let user = user,
                              let idToken = user.idToken?.tokenString else {
                            self.errorMessage = "Failed to get ID token"
                            self.isLoading = false
                            return
                        }
                        
                        // Now call your existing signInWithGoogle method
                        self.signInWithGoogle(idToken: idToken)
                    }
                }
            }
        }
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
