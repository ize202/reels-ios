import SwiftUI
import SharedKit
import VideoPlayerKit
import SupabaseKit

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(db: DB, seriesId: UUID, startingEpisode: Int = 1) {
        print("Initializing FeedView with seriesId: \(seriesId), startingEpisode: \(startingEpisode)")
        _viewModel = StateObject(wrappedValue: FeedViewModel(db: db, seriesId: seriesId, startingEpisode: startingEpisode))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button("Go Back") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "9B79C1"))
                        .cornerRadius(8)
                    }
                } else if !viewModel.feedItems.isEmpty {
                    TabView(selection: $viewModel.currentIndex) {
                        ForEach(Array(viewModel.feedItems.indices), id: \.self) { index in
                            FeedItemView(item: viewModel.feedItems[index], isActive: viewModel.currentIndex == index)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .rotationEffect(.degrees(0)) // Ensures video is in correct orientation
                                .tag(index)
                                .onAppear {
                                    print("Feed item \(index) appeared - playbackId: \(viewModel.feedItems[index].playbackId)")
                                }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onChange(of: viewModel.currentIndex) { newIndex in
                        print("Current index changed to \(newIndex)")
                    }
                    
                    // Add a gesture to swipe down to dismiss
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { gesture in
                                // If swipe direction is mostly downward, dismiss
                                if gesture.translation.height > 100 && 
                                   abs(gesture.translation.height) > abs(gesture.translation.width) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                    )
                } else {
                    Text("No episodes available")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
        )
        .onAppear {
            print("FeedView appeared with \(viewModel.feedItems.count) items")
            if !viewModel.feedItems.isEmpty {
                print("First item playbackId: \(viewModel.feedItems[0].playbackId)")
            }
        }
    }
}

struct FeedItemView: View {
    @State private var isLiked: Bool
    @State private var isSaved: Bool
    @State private var isPlaying: Bool = false
    let item: FeedItem
    let isActive: Bool
    
    init(item: FeedItem, isActive: Bool = false) {
        self.item = item
        self.isActive = isActive
        _isLiked = State(initialValue: item.isLiked)
        _isSaved = State(initialValue: item.isSaved)
        print("Initializing FeedItemView with playbackId: \(item.playbackId), isActive: \(isActive)")
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Mux Video Player
            MuxPlayerView(
                playbackId: item.playbackId,
                autoPlay: isActive,
                isMuted: false,
                metadata: [
                    "title": item.title,
                    "video_id": item.id,
                    "series_id": item.seriesId,
                    "episode_number": String(item.episodeNumber)
                ]
            )
            .onAppear {
                print("Video player appeared with playbackId: \(item.playbackId), isActive: \(isActive)")
                isPlaying = isActive
            }
            .onChange(of: isActive) { active in
                print("isActive changed to \(active) for playbackId: \(item.playbackId)")
                isPlaying = active
            }
            
            // Video Info Overlay
            VStack(alignment: .leading) {
                Spacer()
                
                // Play button overlay (only shown when paused)
                if !isPlaying && isActive {
                    Button(action: {
                        isPlaying = true
                        print("Play button tapped for \(item.playbackId)")
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
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
        // Use mock DB for preview
        let mockDB = DB()
        // Use a mock UUID for preview
        let mockSeriesId = UUID()
        
        FeedView(db: mockDB, seriesId: mockSeriesId)
            .previewDisplayName("Feed View - Full Screen")
            .previewDevice("iPhone 14 Pro")
    }
} 