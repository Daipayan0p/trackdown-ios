import Testing
import Foundation
import Supabase
@testable import trackdown

struct SupabaseAuthRepositoryTests {
    
    @Test("Test signup execution")
    func testSignup() async throws {
        // Setup real Supabase client
        let supabase = Supabase.initSupabase()
        
        let repository = SupabaseAuthRepository(supabase: supabase)
        
        let signUpData = SignUpData(
            name: "Test User",
            email: "d.neogi.coding@gmail.com",
            password: "testpassword123",
            confirmPassword: "testpassword123"
        )
        
        // Execute signup
        try await repository.signUp(signUpData: signUpData)
        
        print("✅ Signup executed successfully - Check your Supabase dashboard")
    }
}
