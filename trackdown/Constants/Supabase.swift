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
                  supabaseURL: URL(string: "https://vzyvfdqjiipdkmiapdnh.supabase.co")!,
                  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6eXZmZHFqaWlwZGttaWFwZG5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NTU0MzUsImV4cCI6MjA2NTIzMTQzNX0.ViWZo-fpyRosnQtzaEFcx5eg2zsIwktpw0GrKh74cJQ"
                )
        return supabase
    }
}

