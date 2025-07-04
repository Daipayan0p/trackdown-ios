//
//  LoginView.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo
            logoImage
            
            // Input Fields
            VStack(spacing: 16) {
                AuthTextField(
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
                
                AuthSecureField(
                    placeholder: "Password",
                    text: $password
                )
            }
            
            // Forgot Password
            forgotPasswordButton
            
            // Login Button
            AuthButton(
                title: "Login",
                isLoading: authVM.isLoading,
                isEnabled: !email.isEmpty && !password.isEmpty
            ) {
                authVM.signIn(email: email, password: password)
            }
            
            // Social Login
            socialLoginSection
            
            Spacer()
            
            NavigationLink(destination: SignUpView()) {
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(Color.customTextColor)
                    Text("Sign Up")
                        .foregroundStyle(Color.customButtonBlue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical)
            .padding(.bottom,40)
        }
        .padding(.horizontal)
        .background(Color.background)
        .alert("Error", isPresented: .constant(authVM.errorMessage != nil)) {
            Button("OK") {
                authVM.clearError()
            }
        } message: {
            Text(authVM.errorMessage ?? "")
        }
    }
    
    // MARK: - View Components
    private var logoImage: some View {
        Image(colorScheme == .light ? "logo" : "logo_dark")
            .resizable()
            .frame(width: 360, height: colorScheme == .light ? 300 : 340)
    }
    
    private var forgotPasswordButton: some View {
        HStack {
            Button("Forgot Password?") {
                // Handle forgot password
            }
            .foregroundColor(Color.customTextColor)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: 18) {
            Text("Or Sign in with")
                .padding(.top, 10)
            
            HStack(spacing: 28) {
                SocialLoginButton(
                    imageName: colorScheme == .light ? "apple" : "apple_white"
                ) {
                    // Handle Apple login
                }
                
                SocialLoginButton(imageName: "google") {
                    authVM.handleGoogleSignIn()
                }
            }
        }
    }
}

#Preview {
    let mockSupabase = Supabase.initSupabase()
    let mockContainer = DIContainer(supabaseClient: mockSupabase)
    AuthRootView(diContainer: mockContainer)
}
