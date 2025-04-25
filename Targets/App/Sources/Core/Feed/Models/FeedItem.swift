import Foundation
import SharedKit
import SupabaseKit

struct FeedItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: URL?
    let playbackId: String  // Mux playback ID
    let seriesId: String
    let series: String      // Series name
    let episodeNumber: Int
    let unlockType: Episode.UnlockType
    let totalEpisodes: Int
    var viewCount: Int
    
    // Computed property to format view count
    var formattedViewCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: viewCount)) ?? "0"
    }
    
    // Computed property to format episode number for analytics
    var formattedEpisodeNumber: String {
        return String(episodeNumber)
    }
}

