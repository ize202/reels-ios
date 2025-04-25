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
    
    let db: DB
    private var fetchTask: Task<Void, Never>?
    
    init(db: DB) {
        self.db = db
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        fetchTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        
        fetchTask = Task.detached {
            do {
                try Task.checkCancellation()
                print("Starting series fetch in detached task...")
                
                let series = try await self.db.fetchAllSeries()
                
                try Task.checkCancellation()
                
                await MainActor.run {
                    print("Fetched \(series.count) series successfully")
                    guard !Task.isCancelled else {
                        print("Fetch task cancelled just before UI update.")
                        return
                    }
                    self.allSeries = series
                    self.featuredSeries = []
                    self.isLoading = false
                    self.errorMessage = nil
                    print("UI updated on MainActor")
                }
            } catch is CancellationError {
                print("Fetch task was cancelled.")
                 await MainActor.run {
                     if self.isLoading {
                         self.isLoading = false
                         print("Reset isLoading due to cancellation")
                     }
                 }
            } catch let error as NSError {
                await MainActor.run {
                    print("Error fetching series - Domain: \(error.domain), Code: \(error.code), Description: \(error.localizedDescription)")
                    if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error {
                        print("Underlying error: \(underlyingError)")
                    }
                    self.isLoading = false
                    self.errorMessage = "Failed to load series: \(error.localizedDescription)"
                    print("Error UI updated on MainActor")
                }
            } catch {
                 await MainActor.run {
                    print("Unknown error fetching series: \(error)")
                    self.isLoading = false
                    self.errorMessage = "Failed to load series. Please try again."
                    print("Unknown error UI updated on MainActor")
                }
            }
        }
    }
} 