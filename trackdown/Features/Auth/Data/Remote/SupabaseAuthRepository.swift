//
//  SupabaseAuthRepository.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import Foundation
import Supabase

class SupabaseAuthRepository: AuthRepositoryProtocol {
    
    
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func signIn(credentials: AuthCredentials) async throws -> User {
        do {
            let session = try await supabase.auth.signIn(
                email: credentials.email,
                password: credentials.password
            )
            print(session)
            return mapToUser(from: session)
        } catch {
            if(error.localizedDescription=="Email not confirmed"){
                print("Yes")
                try! await resendConfirmationEmail(email: credentials.email)
            }
            throw mapSupabaseError(error)
        }
    }
    
    func signInWithGoogle(idToken:String) async throws -> User {
            
        do {
            let session = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
            
            // Use the existing mapToUser helper method for consistency
            return mapToUser(from: session)
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    
    func signUp(signUpData: SignUpData) async throws {
        do {
            _ = try await supabase.auth.signUp(
                email: signUpData.email,
                password: signUpData.password,
                redirectTo: URL(string: "io.supabase.track-down://login-callback")
            )
            
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    func getCurrentUser() async -> User? {
        guard let session = supabase.auth.currentSession else { return nil }
        return mapToUser(from: session)
    }
    
    func handleDeepLink(_ url: URL) async throws {
        try await supabase.auth.session(from: url)
    }
    
    func observeAuthState() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            Task {
                for await state in supabase.auth.authStateChanges {
                    if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                        let isAuthenticated = state.session != nil
                        continuation.yield(isAuthenticated)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func mapToUser(from session: Session) -> User {
        User(
            id: session.user.id.uuidString,
            email: session.user.email ?? "",
            name: session.user.userMetadata["name"]?.description ?? "",
            session: session
        )
    }
    
    private func mapSupabaseError(_ error: Error) -> AuthError {
        return AuthError.unknown(error.localizedDescription)
    }
    
    func resendConfirmationEmail(email: String) async throws {
        do {
            try await supabase.auth.resend(
                email: email,
                type: .signup,
                emailRedirectTo: URL(string: "io.supabase.track-down://login-callback")
            )
        } catch {
            throw mapSupabaseError(error)
        }
    }
}


