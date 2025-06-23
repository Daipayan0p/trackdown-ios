//
//  trackdownApp.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/05/25.
//

import SwiftUI

@main
struct trackdownApp: App {
    private let diContainer: DIContainer
        init() {
            self.diContainer = DIContainer(supabaseClient: Supabase.initSupabase())
        }
    var body: some Scene {
        WindowGroup {
            AuthRootView(diContainer: diContainer)
        }
    }
}
