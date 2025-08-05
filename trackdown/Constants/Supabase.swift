//
//  Supabase.swift
//  trackdown
//
//  Created by Daipayan Neogi on 18/06/25.
//

import Foundation
import Supabase

class Supabase{
    static func initSupabase() -> SupabaseClient{
        let supabase = SupabaseClient(
          supabaseURL: URL(string: "Add Your URL")!,
          supabaseKey: "Add Your Key"
        )
        return supabase
    }
}

