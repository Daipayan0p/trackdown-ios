//
//  AuthUseCases.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation

class SignInUseCase: SignInUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(credentials: AuthCredentials) async throws -> User {
        return try await repository.signIn(credentials: credentials)
    }
}


class SignOutUseCase: SignOutUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.signOut()
    }
}

class SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(signUpData: SignUpData) async throws {
        guard signUpData.isValid else {
            throw AuthError.invalidInput
        }
        try await repository.signUp(signUpData: signUpData)
    }
}

class ObserveAuthUseCase: ObserveAuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> AsyncStream<Bool> {
        return repository.observeAuthState()
    }
}

class SignInWithGoogleUseCase: SignInWithGoogleProtocol{
    func execute(idToken:String) async throws -> User {
        return try await repository.signInWithGoogle(idToken: idToken)
    }
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
}
