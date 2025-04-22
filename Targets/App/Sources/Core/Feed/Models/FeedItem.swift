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
    var isLiked: Bool
    var isSaved: Bool
    var viewCount: Int
    
    // Computed property to format view count
    var formattedViewCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: viewCount)) ?? "0"
    }
}

// MARK: - Mock Data
extension FeedItem {
    static var mockItems: [FeedItem] = [
        FeedItem(
            id: "1",
            title: "The Beginning",
            description: "A thrilling start to our new series. Watch as the story unfolds in this exciting first episode.",
            thumbnailURL: nil,
            playbackId: "kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00", // Demo video from Mux
            seriesId: "series1",
            episodeNumber: 1,
            totalEpisodes: 10,
            isLiked: false,
            isSaved: false,
            viewCount: 1234
        ),
        FeedItem(
            id: "2",
            title: "The Mystery Deepens",
            description: "The plot thickens as our characters discover something unexpected that changes everything.",
            thumbnailURL: nil,
            playbackId: "kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00", // Another demo video
            seriesId: "series1",
            episodeNumber: 2,
            totalEpisodes: 10,
            isLiked: true,
            isSaved: true,
            viewCount: 2345
        ),
        FeedItem(
            id: "3",
            title: "The Revelation",
            description: "A shocking revelation leaves everyone questioning what they thought they knew.",
            thumbnailURL: nil,
            playbackId: "kXq1Fuv8iYSg00u7014T1OxFAiXK9pTtY3zsn5mkwn3f00", // Another demo video
            seriesId: "series1",
            episodeNumber: 3,
            totalEpisodes: 10,
            isLiked: false,
            isSaved: true,
            viewCount: 3456
        )
    ]
}