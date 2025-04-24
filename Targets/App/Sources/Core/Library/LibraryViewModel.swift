//
//  LibraryViewModel.swift
//  App
//

import Foundation
import SwiftUI
import SupabaseKit
import Combine // <-- Import Combine

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
    
    private var db: DB
    private var cancellables = Set<AnyCancellable>() // <-- Store Combine subscriptions
    
    init(db: DB) {
        self.db = db
        // Fetch data once on initialization
        fetchLibraryData()
        
        // Observe the notification
        NotificationCenter.default.publisher(for: .didUpdateUserLibrary)
            .receive(on: DispatchQueue.main) // Ensure UI updates on main thread
            .sink { [weak self] _ in
                print("[LibraryVM] Received didUpdateUserLibrary notification. Fetching data.")
                self?.fetchLibraryData() // Refresh data
            }
            .store(in: &cancellables) // Store subscription
    }
    
    // Optional: Add deinit to clean up observer if strictly needed, though .store(in:) handles it well with object lifetime
    // deinit {
    //     // NotificationCenter automatically removes observers when the object is deallocated,
    //     // but explicit removal or using .store(in:) is good practice.
    //     print("[LibraryVM] Deinit - cancelling observers")
    // }

    func fetchLibraryData() {
        // Prevent fetching if already loading
        guard !isLoading else {
            print("[LibraryVM] Fetch requested but already loading. Skipping.")
            return
        }
        
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