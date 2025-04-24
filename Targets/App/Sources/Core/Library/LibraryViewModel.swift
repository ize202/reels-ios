//
//  LibraryViewModel.swift
//  App
//

import Foundation
import SwiftUI
import SupabaseKit // <-- Import SupabaseKit

// --- Data Models ---

// Represents a series the user is currently watching
struct WatchedSeries: Identifiable {
    let id = UUID()
    let seriesId: String // Link to the actual series data
    let title: String
    let lastWatchedEpisode: Int
    let totalEpisodes: Int
    let coverUrl: URL? // <-- Changed from thumbnailURL
    
    var progressString: String {
        "EP.\(lastWatchedEpisode)"
    }
}

// Represents a series saved by the user
struct SavedSeries: Identifiable {
    let id = UUID()
    let seriesId: String // Link to the actual series data
    let title: String
    let totalEpisodes: Int
    let coverUrl: URL? // <-- Changed from thumbnailURL
    
    var episodesString: String {
        "All \(totalEpisodes) EP"
    }
}

// --- ViewModel ---

@MainActor
class LibraryViewModel: ObservableObject {
    
    @Published var recentlyWatched: [WatchedSeries] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var db: DB // <-- Add DB instance
    
    init(db: DB) { // <-- Inject DB
        self.db = db
        fetchLibraryData()
    }
    
    func fetchLibraryData() {
        isLoading = true
        errorMessage = nil
        
        guard let userId = db.currentUser?.id else {
            errorMessage = "User not logged in."
            isLoading = false
            print("[LibraryViewModel] Error: Cannot fetch library, user not logged in.")
            // Consider how to handle this - maybe show a sign-in prompt?
            return
        }
        
        Task {
            do {
                let libraryDetails = try await db.fetchUserLibraryDetails(userId: userId)
                
                // Process fetched details
                var watched: [WatchedSeries] = []
                
                for detail in libraryDetails {
                    // Add to recently watched if there's a last watched episode
                    if let lastEpisode = detail.lastWatchedEpisodeNumber, lastEpisode > 0 {
                        watched.append(WatchedSeries(
                            seriesId: detail.seriesId.uuidString,
                            title: detail.title,
                            lastWatchedEpisode: lastEpisode,
                            totalEpisodes: detail.totalEpisodes,
                            coverUrl: URL(string: detail.coverUrl ?? "") // Handle nil cover URL
                        ))
                    }
                }
                
                // Sort recently watched (optional, maybe by last access time if available)
                // self.recentlyWatched = watched.sorted { ... }
                self.recentlyWatched = watched
                
                self.isLoading = false
                
            } catch {
                self.errorMessage = "Failed to load library: \(error.localizedDescription)"
                self.isLoading = false
                print("[LibraryViewModel] Error fetching library data: \(error)")
            }
        }
    }
} 