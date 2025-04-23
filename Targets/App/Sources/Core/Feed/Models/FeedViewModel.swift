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
            
            // Filter episodes with valid playback URLs
            let validEpisodes = episodes.filter { episode in
                let isValidUrl = !episode.playbackUrl.isEmpty && 
                                (episode.playbackUrl.contains("mux.com") || 
                                 !episode.playbackUrl.contains("/") && !episode.playbackUrl.contains(":"))
                if !isValidUrl {
                    print("⚠️ Episode \(episode.episodeNumber) has an invalid playbackUrl: \(episode.playbackUrl)")
                }
                return isValidUrl
            }
            
            if validEpisodes.isEmpty {
                print("No valid playback URLs found for any episodes in series: \(series.title)")
                self.errorMessage = "No playable episodes available for this series."
                self.isLoading = false
                return
            }
            
            print("Found \(validEpisodes.count) episodes with valid playback URLs")
            
            // Create a test Mux playback ID if we need one for testing
            // This is a placeholder. In a real app, each episode would have its own playback ID
            let testPlaybackId = "IQDLWkPW5aT38ttFO5RSHw400nGHPjzPKG02Bw1LIExzA"
            
            // Convert episodes to feed items
            self.feedItems = validEpisodes.map { episode in
                // Log the playback URL for debugging
                print("Episode \(episode.episodeNumber) playbackUrl: \(episode.playbackUrl)")
                
                // Decide whether to use the episode's playback URL or the test ID
                let playbackId = episode.playbackUrl.isEmpty || episode.playbackUrl == "placeholder" 
                    ? testPlaybackId 
                    : episode.playbackUrl
                
                return FeedItem(
                    id: episode.id.uuidString,
                    title: "\(series.title) - Episode \(episode.episodeNumber)",
                    description: series.description ?? "No description available",
                    thumbnailURL: series.coverUrl != nil ? URL(string: series.coverUrl!) : nil,
                    playbackId: playbackId,
                    seriesId: series.id.uuidString,
                    episodeNumber: episode.episodeNumber,
                    totalEpisodes: episodes.count,
                    isLiked: false,  // We'd need to fetch this from user data
                    isSaved: false,  // We'd need to fetch this from user data
                    viewCount: 0     // We'd need real view counts from analytics
                )
            }.sorted(by: { $0.episodeNumber < $1.episodeNumber })
            
            print("Processed \(self.feedItems.count) feed items, first item playbackId: \(self.feedItems.first?.playbackId ?? "none")")
            
            // Set the starting episode index
            if startingEpisode > 1 && startingEpisode <= feedItems.count {
                // Convert to 0-based index
                currentIndex = startingEpisode - 1
                print("Setting current index to \(currentIndex) (startingEpisode: \(startingEpisode))")
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load episodes: \(error.localizedDescription)"
            print("Error loading feed items: \(error)")
        }
    }
} 