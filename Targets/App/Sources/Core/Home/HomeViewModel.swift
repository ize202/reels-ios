//
//  HomeViewModel.swift
//  App
//

import Foundation
import SwiftUI
import SupabaseKit

@MainActor
class HomeViewModel: ObservableObject {
    @Published var featuredSeries: [Series] = []
    @Published var allSeries: [Series] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Make db variable so it can be updated when the real one is available
    var db: DB
    
    init(db: DB) {
        self.db = db
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let series = try await db.fetchAllSeries()
            
            // Put all series in the grid
            allSeries = series
            
            // Keep featuredSeries empty since we're not using it anymore
            featuredSeries = []
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load series. Please try again."
            print("Error fetching series: \(error)")
        }
    }
} 