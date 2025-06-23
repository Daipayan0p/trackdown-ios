//
//  AuthRootView.swift
//  trackdown
//
//  Created by Daipayan Neogi on 23/06/25.
//

import SwiftUI
import Supabase

struct AuthRootView: View {
    @StateObject private var authViewModel: AuthViewModel
    
    init(diContainer: DIContainer) {
        _authViewModel = StateObject(wrappedValue: diContainer.authViewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.isAuthenticated {
                    CountDownHome()
                } else {
                    LoginView()
                }
            }
        }
        .environmentObject(authViewModel)
        .onOpenURL { url in
            authViewModel.handleDeepLink(url)
        }
    }
}

#Preview {
    let mockSupabase = Supabase.initSupabase() 
    let mockContainer = DIContainer(supabaseClient: mockSupabase)
    AuthRootView(diContainer: mockContainer)
}
