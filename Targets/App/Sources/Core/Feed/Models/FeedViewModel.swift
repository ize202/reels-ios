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
    
    init(db: DB, seriesId: UUID, startingEpisode: Int = 1) {
        self.db = db
        self.seriesId = seriesId
        
        // Load the feed items immediately
        Task {
            await loadFeedItems(startingEpisode: startingEpisode)
        }
    }
    
    func loadFeedItems(startingEpisode: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
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
            // Find the index in feedItems corresponding to the startingEpisode number
            if let targetIndex = self.feedItems.firstIndex(where: { $0.episodeNumber == startingEpisode }) {
                currentIndex = targetIndex
                print("Setting current index to \(currentIndex) for startingEpisode: \(startingEpisode)")
            } else if startingEpisode > 1 && !self.feedItems.isEmpty {
                // Fallback: if specific episode number not found (maybe it was filtered out),
                // try to respect the intent if startingEpisode > 1, but clamp to valid range.
                // This case might indicate data inconsistency.
                print("Warning: startingEpisode \(startingEpisode) not found in valid episodes. Clamping index.")
                currentIndex = min(startingEpisode - 1, self.feedItems.count - 1)
            } else {
                // Default to 0 if startingEpisode is 1 or feedItems is empty
                currentIndex = 0
                 print("Setting current index to 0 (startingEpisode: \(startingEpisode))")
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