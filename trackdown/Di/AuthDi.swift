//
//  AuthDi.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation
import Supabase

class DIContainer {
    private let supabaseClient: SupabaseClient
    
    init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    // MARK: - Repository
    lazy var authRepository: AuthRepositoryProtocol = {
        SupabaseAuthRepository(supabase: supabaseClient)
    }()
    
    // MARK: - Use Cases
    lazy var signInUseCase: SignInUseCaseProtocol = {
        SignInUseCase(repository: authRepository)
    }()
    
    lazy var signUpUseCase: SignUpUseCaseProtocol = {
        SignUpUseCase(repository: authRepository)
    }()
    
    lazy var signOutUseCase: SignOutUseCaseProtocol = {
        SignOutUseCase(repository: authRepository)
    }()
    
    lazy var observeAuthUseCase: ObserveAuthUseCaseProtocol = {
        ObserveAuthUseCase(repository: authRepository)
    }()
    
    lazy var signInWithGoogleUseCase: SignInWithGoogleProtocol = {
        SignInWithGoogleUseCase(repository: authRepository)
    }()
    
    // MARK: - ViewModels
    @MainActor
    lazy var authViewModel: AuthViewModel = {
        AuthViewModel(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
            signOutUseCase: signOutUseCase,
            observeAuthUseCase: observeAuthUseCase,
            repository: authRepository,
            signInWithGoogleUseCase: signInWithGoogleUseCase
        )
    }()
}
