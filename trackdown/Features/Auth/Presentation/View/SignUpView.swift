import SwiftUI

struct SignUpView: View{
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") && email.contains(".") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    @EnvironmentObject private var authVM: AuthViewModel
    var body: some View {
        VStack(spacing: 20) {
            // Logo
            Image(colorScheme == .light ? "logo" : "logo_dark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 360, height: colorScheme == .light ? 300 : 340)
            
            // Input Fields
            VStack(spacing: 16) {
                AuthTextField(
                    placeholder: "Name",
                    text: $name
                )
                
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
                
                AuthSecureField(
                    placeholder: "Confirm Password",
                    text: $confirmPassword
                )
                
                // Password validation feedback
                if !password.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(password.count >= 6 ? .green : .red)
                                .font(.caption)
                            Text("At least 6 characters")
                                .font(.caption)
                                .foregroundColor(password.count >= 6 ? .green : .red)
                        }
                        
                        if !confirmPassword.isEmpty {
                            HStack {
                                Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                    .font(.caption)
                                Text("Passwords match")
                                    .font(.caption)
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                }
            }
            
            // Sign Up Button
            AuthButton(
                title: "Sign Up",
                isLoading: authVM.isLoading,
                isEnabled: isFormValid
            ) {
                let signUpData = SignUpData(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                    password: password,
                    confirmPassword: confirmPassword
                )
                
                Task {
                    authVM.signUp(signUpData: signUpData)
                    // Wait for 1 second (in nanoseconds: 1_000_000_000)
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    
                    if (authVM.isLoading == false) {
                        dismiss()
                    }
                }
                             
            }
            
            // Sign In Link
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Already have an account?")
                        .foregroundStyle(Color.customTextColor)
                    Text("Sign In")
                        .foregroundStyle(Color.customButtonBlue)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .background(Color.background)
        .alert("Error", isPresented: .constant(authVM.errorMessage != nil)) {
            Button("OK") {
                authVM.clearError()
            }
        } message: {
            Text(authVM.errorMessage ?? "")
        }
        .onChange(of: authVM.isAuthenticated) { _, isAuth in
            if isAuth {
                dismiss()
            }
        }
    }
}
