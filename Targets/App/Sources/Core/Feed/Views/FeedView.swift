import SwiftUI
import SharedKit
import VideoPlayerKit

struct FeedView: View {
    @State private var currentIndex: Int = 0
    @State private var feedItems: [FeedItem]
    
    init(feedItems: [FeedItem] = FeedItem.mockItems) {
        _feedItems = State(initialValue: feedItems)
    }
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentIndex) {
                ForEach(Array(feedItems.enumerated()), id: \.element.id) { index, item in
                    FeedItemView(item: item)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .rotationEffect(.degrees(0)) // Ensures video is in correct orientation
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct FeedItemView: View {
    @State private var isLiked: Bool
    @State private var isSaved: Bool
    let item: FeedItem
    
    init(item: FeedItem) {
        self.item = item
        _isLiked = State(initialValue: item.isLiked)
        _isSaved = State(initialValue: item.isSaved)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Mux Video Player
            MuxPlayerView(
                playbackId: item.playbackId,
                autoPlay: true,
                isMuted: false,
                metadata: [
                    "title": item.title,
                    "video_id": item.id,
                    "series_id": item.seriesId,
                    "episode_number": item.episodeNumber
                ]
            )
            
            // Video Info Overlay
            VStack(alignment: .leading) {
                Spacer()
                
                HStack(alignment: .bottom) {
                    // Video Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(item.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                        
                        Text("Episode \(item.episodeNumber) of \(item.totalEpisodes)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 32)
                    
                    Spacer()
                    
                    // Action Buttons
                    FeedActionButtons(
                        item: item,
                        isLiked: $isLiked,
                        isSaved: $isSaved,
                        onLike: {
                            isLiked.toggle()
                            // Implement like functionality
                        },
                        onSave: {
                            isSaved.toggle()
                            // Implement save functionality
                        },
                        onEpisodes: {
                            // Show episodes modal
                        },
                        onShare: {
                            // Implement share functionality
                        }
                    )
                }
            }
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Preview Provider
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Full screen preview
            FeedView()
                .previewDisplayName("Feed View - Full Screen")
                .previewDevice("iPhone 14 Pro")
            
            // Single item preview
            FeedItemView(item: FeedItem.mockItems[0])
                .previewDisplayName("Single Item")
                .frame(width: 390, height: 844) // iPhone 14 Pro dimensions
                .background(Color.black)
        }
    }
} 