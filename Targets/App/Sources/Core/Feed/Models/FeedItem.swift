import Foundation
import SharedKit

struct FeedItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: URL?
    let playbackId: String  // Mux playback ID
    let seriesId: String
    let episodeNumber: Int
    let totalEpisodes: Int
    var viewCount: Int
    
    // Computed property to format view count
    var formattedViewCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: viewCount)) ?? "0"
    }
}

