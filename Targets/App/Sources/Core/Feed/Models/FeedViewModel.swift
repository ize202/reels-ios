import Foundation
import SupabaseKit
import SwiftUI
import SharedKit

@MainActor
class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentIndex: Int = 0
    
    private var db: DB
    private var seriesId: UUID
    
    init(db: DB, seriesId: UUID, startingEpisode: Int? = nil) {
        self.db = db
        self.seriesId = seriesId
        
        // Load the feed items immediately, passing the optional starting episode
        Task {
            await loadFeedItems(initialStartingEpisode: startingEpisode)
        }
    }
    
    func loadFeedItems(initialStartingEpisode: Int? = nil) async {
        isLoading = true
        errorMessage = nil
        
        // Determine the effective starting episode
        var effectiveStartingEpisode: Int = 1 // Default to 1
        
        if let providedStartingEpisode = initialStartingEpisode {
            effectiveStartingEpisode = providedStartingEpisode
            print("[FeedVM] Using provided starting episode: \(effectiveStartingEpisode)")
        } else {
            // No starting episode provided, fetch from library
            if let userId = db.currentUser?.id {
                 print("[FeedVM] No starting episode provided. Fetching last watched for series: \(seriesId), user: \(userId)")
                do {
                    let libraryDetails = try await db.fetchUserLibraryDetails(userId: userId, seriesId: seriesId)
                    if let detail = libraryDetails.first, let lastWatched = detail.lastWatchedEpisodeNumber {
                        // Use fetched episode number only if it's greater than 0
                        if lastWatched > 0 {
                            effectiveStartingEpisode = lastWatched
                            print("[FeedVM] Fetched last watched episode: \(effectiveStartingEpisode)")
                        } else {
                            print("[FeedVM] Fetched last watched episode is 0 or null. Defaulting to 1.")
                        }
                    } else {
                         print("[FeedVM] No library entry found for this series. Defaulting to episode 1.")
                    }
                } catch {
                     print("[FeedVM] Error fetching last watched episode, defaulting to 1: \(error)")
                     // Don't block loading, just default to 1
                }
            } else {
                 print("[FeedVM] User not logged in, defaulting to episode 1.")
                 // Default to 1 if user isn't logged in
            }
        }
        
        // --- Now proceed with fetching series/episodes --- 
        do {
            // Fetch the series to get series details
            print("Fetching series with ID: \(seriesId)")
            let allSeries = try await db.fetchAllSeries()
            guard let series = allSeries.first(where: { $0.id == seriesId }) else {
                throw NSError(domain: "FeedViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Series not found"])
            }
            
            // Fetch episodes for this series
            print("Fetching episodes for series: \(series.title)")
            let episodes = try await db.fetchEpisodes(forSeriesId: seriesId)
            
            if episodes.isEmpty {
                print("No episodes found for series: \(series.title)")
                self.errorMessage = "No episodes available for this series."
                self.isLoading = false
                return
            }
            
            print("Found \(episodes.count) episodes for series: \(series.title)")
            
            // Sort episodes by episode number before filtering
            let sortedEpisodes = episodes.sorted { $0.episodeNumber < $1.episodeNumber }
            
            // Filter episodes with valid playback URLs
            let validEpisodes = sortedEpisodes.filter { episode in
                return !episode.playbackUrl.isEmpty && episode.playbackUrl != "placeholder"
            }
            
            // Check if there are any valid episodes after filtering
            guard !validEpisodes.isEmpty else {
                // If no valid episodes, set an appropriate message and stop loading
                print("No valid episodes found for series: \(series.title) after filtering.")
                self.errorMessage = "No playable episodes available for this series."
                self.isLoading = false
                return
            }
            
            // Use actual playback URLs from the valid episodes
            self.feedItems = validEpisodes.map { episode in
                // Log the playback URL for debugging
                print("Episode \(episode.episodeNumber) playbackUrl: \(episode.playbackUrl)")
                
                return FeedItem(
                    id: episode.id.uuidString,
                    title: "\(series.title) - Episode \(episode.episodeNumber)",
                    description: series.description ?? "No description available",
                    thumbnailURL: series.coverUrl != nil ? URL(string: series.coverUrl!) : nil,
                    playbackId: episode.playbackUrl, // Use the actual playbackUrl
                    seriesId: series.id.uuidString,
                    episodeNumber: episode.episodeNumber,
                    totalEpisodes: episodes.count, // Use total count from original episodes list for accuracy
                    viewCount: 0     // TODO: Fetch view counts
                )
            }
            
            print("Processed \(self.feedItems.count) feed items, first item playbackId: \(self.feedItems.first?.playbackId ?? "none")")
            
            // Set the starting episode index based on the *filtered* feedItems count
            // Find the index in feedItems corresponding to the effectiveStartingEpisode number
            if let targetIndex = self.feedItems.firstIndex(where: { $0.episodeNumber == effectiveStartingEpisode }) {
                currentIndex = targetIndex
                print("[FeedVM] Setting current index to \(currentIndex) for effectiveStartingEpisode: \(effectiveStartingEpisode)")
            } else if effectiveStartingEpisode > 1 && !self.feedItems.isEmpty {
                // Fallback: if specific episode number not found (maybe it was filtered out),
                // try to respect the intent if startingEpisode > 1, but clamp to valid range.
                // This case might indicate data inconsistency.
                print("Warning: effectiveStartingEpisode \(effectiveStartingEpisode) not found in valid episodes. Clamping index.")
                currentIndex = min(effectiveStartingEpisode - 1, self.feedItems.count - 1)
            } else {
                // Default to 0 if startingEpisode is 1 or feedItems is empty
                currentIndex = 0
                 print("[FeedVM] Setting current index to 0 (effectiveStartingEpisode: \(effectiveStartingEpisode))")
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load episodes: \(error.localizedDescription)"
            print("Error loading feed items: \(error)")
        }
    }
    
    /// Records the last viewed episode for the current series in the user library.
    func recordWatchHistory() {
        // Ensure we have a user and the index is valid
        guard let userId = db.currentUser?.id, 
              currentIndex >= 0 && currentIndex < feedItems.count else {
            print("Watch History: Cannot record. User not logged in or index out of bounds (\(currentIndex)).")
            return
        }
        
        let currentItem = feedItems[currentIndex]
        
        // Ensure the seriesId and episodeId are valid UUIDs
        guard let seriesUUID = UUID(uuidString: currentItem.seriesId),
              let episodeUUID = UUID(uuidString: currentItem.id) else {
            print("Watch History: Cannot record. Invalid Series ID (\(currentItem.seriesId)) or Episode ID (\(currentItem.id)).")
            return
        }
        
        print("Watch History: Recording User: \(userId), Series: \(seriesUUID), Last Episode: \(episodeUUID) (Index: \(currentIndex))")
        
        // Call the backend function asynchronously
        Task {
            await db.updateWatchHistory(userId: userId, seriesId: seriesUUID, lastEpisodeId: episodeUUID)
        }
    }
} 