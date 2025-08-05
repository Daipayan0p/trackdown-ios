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
    
    // Updated async Google Sign In method
    func handleGoogleSignIn() {
        Task {
            await performAuthAction { [self] in
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let presentingViewController = window.rootViewController else {
                    throw GoogleSignInError.noPresentingViewController
                }
                
                // Sign in with Google
                let signInResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDSignInResult, Error>) in
                    GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let result = result {
                            continuation.resume(returning: result)
                        } else {
                            continuation.resume(throwing: GoogleSignInError.noResult)
                        }
                    }
                }
                
                // Refresh tokens if needed
                let user = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<GIDGoogleUser, Error>) in
                    signInResult.user.refreshTokensIfNeeded { user, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let user = user {
                            continuation.resume(returning: user)
                        } else {
                            continuation.resume(throwing: GoogleSignInError.noUser)
                        }
                    }
                }
                
                // Get ID token
                guard let idToken = user.idToken?.tokenString else {
                    throw GoogleSignInError.noIdToken
                }
                
                // Use the existing signInWithGoogle use case
                let authUser = try await signInWithGoogleUseCase.execute(idToken: idToken)
                currentUser = authUser
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
        } catch let googleError as GoogleSignInError {
            errorMessage = googleError.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
}

// Custom error enum for Google Sign-In specific errors
enum GoogleSignInError: LocalizedError {
    case noPresentingViewController
    case noResult
    case noUser
    case noIdToken
    
    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            return "Unable to get presenting view controller"
        case .noResult:
            return "Failed to get sign in result"
        case .noUser:
            return "Failed to get user after token refresh"
        case .noIdToken:
            return "Failed to get ID token"
        }
    }
}
