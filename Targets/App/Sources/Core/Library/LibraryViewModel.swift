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
    var coverImage: UIImage? = nil // <-- Add property for loaded image
    
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
                print("[LibraryVM] Assigned basic recentlyWatched data (\(watched.count) items). Starting image fetch.")
                
                // --- Now fetch images asynchronously ---
                await fetchCoverImages(for: watched)
                
            } catch {
                self.errorMessage = "Failed to load library: \(error.localizedDescription)"
                self.isLoading = false
                print("[LibraryViewModel] Error fetching library data: \(error)")
            }
        }
    }
    
    // Helper function to fetch images
    private func fetchCoverImages(for seriesList: [WatchedSeries]) async {
        // Create tasks for each series with a valid URL
        await withTaskGroup(of: (String, UIImage?).self) { group in
            for series in seriesList where series.coverUrl != nil {
                group.addTask {
                    // Attempt to download the image
                    var image: UIImage? = nil
                    if let url = series.coverUrl {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            image = UIImage(data: data)
                            // print("[LibraryVM] Image downloaded successfully for Series ID: \(series.seriesId)")
                        } catch {
                            print("[LibraryVM] Error downloading image for Series ID: \(series.seriesId) from \(url): \(error.localizedDescription)")
                        }
                    }
                    // Return tuple of (seriesId, optional UIImage)
                    return (series.seriesId, image)
                }
            }
            
            // Process results as they complete
            for await (seriesId, image) in group {
                if let image = image {
                    // Find the index of the series in our main array and update its image
                    if let index = self.recentlyWatched.firstIndex(where: { $0.seriesId == seriesId }) {
                        // Update the image on the main thread
                        // Although @MainActor handles the class, explicit is safer for array updates triggered by background tasks
                        DispatchQueue.main.async {
                            self.recentlyWatched[index].coverImage = image
                            // print("[LibraryVM] Updated coverImage for Series ID: \(seriesId)")
                        }
                    }
                }
            }
        }
        print("[LibraryVM] Image fetching complete.")
    }
} 