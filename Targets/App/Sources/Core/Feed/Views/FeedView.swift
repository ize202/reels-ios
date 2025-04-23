import SwiftUI
import SharedKit
import VideoPlayerKit
import SupabaseKit

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var likedItems: [LikeAnimation] = []
    @State private var scrollIndex: Int = 0
    
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
                    feedScrollView(size: geometry.size, safeArea: geometry.safeAreaInsets)
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
                
                // Show like animations
                ForEach(likedItems) { like in
                    LikeAnimationView(like: like)
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
            scrollIndex = viewModel.currentIndex
        }
    }
    
    @ViewBuilder
    private func feedScrollView(size: CGSize, safeArea: EdgeInsets) -> some View {
        // We use UIScrollView-based tricks for performance
        // This approach gives us better control and snapping behavior
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.feedItems.indices, id: \.self) { index in
                    FeedReelView(
                        item: viewModel.feedItems[index],
                        size: size,
                        safeArea: safeArea,
                        isLiked: Binding(
                            get: { viewModel.feedItems[index].isLiked },
                            set: { viewModel.feedItems[index].isLiked = $0 }
                        ),
                        isSaved: Binding(
                            get: { viewModel.feedItems[index].isSaved },
                            set: { viewModel.feedItems[index].isSaved = $0 }
                        ),
                        isCurrentlyActive: viewModel.currentIndex == index,
                        addLikeAnimation: { position in
                            addLikeAnimation(at: position)
                        }
                    )
                    // Use containerRelativeFrame for height, let ScrollView handle width
                    .containerRelativeFrame(.vertical) 
                    .id(index)
                    .onAppear {
                        // When this item appears, update the current index
                        viewModel.currentIndex = index
                    }
                }
            }
            // Ensure the layout targets the views correctly for paging
            .scrollTargetLayout() 
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging) // Use paging for TikTok-like snapping
    }
    
    private func addLikeAnimation(at position: CGPoint) {
        let id = UUID()
        likedItems.append(.init(id: id, position: position, isAnimated: false))
        
        // Animate the like
        withAnimation(.snappy(duration: 1.2), completionCriteria: .logicallyComplete) {
            if let index = likedItems.firstIndex(where: { $0.id == id }) {
                likedItems[index].isAnimated = true
            }
        } completion: {
            // Remove the animation once it's finished
            likedItems.removeAll(where: { $0.id == id })
        }
    }
}

struct FeedReelView: View {
    let item: FeedItem
    let size: CGSize
    let safeArea: EdgeInsets
    @Binding var isLiked: Bool
    @Binding var isSaved: Bool
    let isCurrentlyActive: Bool // This indicates if the view *should* be playing based on viewModel.currentIndex
    @State private var isMuted: Bool = false
    @State private var isVisible: Bool = false // Tracks actual visibility based on scroll position
    let addLikeAnimation: (CGPoint) -> Void
    
    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .scrollView(axis: .vertical))
            
            MuxPlayerView(
                playbackId: item.playbackId,
                 // We now control play/pause based on calculated visibility, not just isCurrentlyActive
                autoPlay: isVisible, 
                isMuted: isMuted
            )
            .id("\(item.id)_\(item.playbackId)") // Use playbackId for stability if item ID changes unnecessarily
            .preference(key: OffsetKey.self, value: rect)
            .onPreferenceChange(OffsetKey.self) { rect in
                // Use the playPause function to update visibility state
                updateVisibility(rect)
            }
            .overlay(alignment: .bottom) {
                // Video Info Overlay
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
                    VStack(spacing: 24) {
                        Button(action: {
                            isMuted.toggle()
                            print("Audio toggled to \(isMuted ? "muted" : "unmuted")")
                        }) {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        // Like Button
                        Button(action: {
                            isLiked.toggle()
                            // Add haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 24))
                                .foregroundColor(isLiked ? .red : .white)
                        }
                        .symbolEffect(.bounce, value: isLiked)
                        
                        // Save Button
                        Button(action: {
                            isSaved.toggle()
                            // Add haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 24))
                                .foregroundColor(isSaved ? Color(hex: "9B79C1") : .white)
                        }
                        .symbolEffect(.bounce, value: isSaved)
                        
                        // Episodes Button
                        Button(action: {
                            // Show episodes modal
                        }) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        // Share Button
                        Button(action: {
                            // Implement share functionality
                        }) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, safeArea.bottom + 15)
            }
            .onTapGesture(count: 2) { position in
                // Double tap to like
                isLiked = true
                addLikeAnimation(position)
                
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            }
            // Consider adding a single tap gesture for play/pause toggle
            .onTapGesture {
                 // Example: Toggle mute on single tap (or implement play/pause control later)
                 // isMuted.toggle() 
            }
        }
        // Ensure the FeedReelView itself doesn't absorb gestures meant for the ScrollView
        .contentShape(Rectangle()) 
    }
    
    /// Update visibility state based on scroll position
    private func updateVisibility(_ rect: CGRect) {
        // Check if the center of the view is within the visible bounds
        let isNowVisible = -rect.minY < (size.height * 0.5) && rect.minY < (size.height * 0.5)
        
        if isNowVisible != isVisible {
            isVisible = isNowVisible
            print("Video \(item.episodeNumber) visibility changed to: \(isVisible)")
            
            // If it just became visible, ensure it plays (MuxPlayerView handles autoPlay based on isVisible)
            // If it just became invisible, it will pause (MuxPlayerView handles this via autoPlay=false)
        }
        
        // Add logic here later if we need to explicitly seek to zero when far off-screen
        // For now, rely on MuxPlayerView pausing when autoPlay becomes false
    }
}

// MARK: - Animation Models and Views
struct LikeAnimation: Identifiable {
    let id: UUID
    let position: CGPoint
    var isAnimated: Bool
}

struct LikeAnimationView: View {
    let like: LikeAnimation
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: like.isAnimated ? 70 : 100))
            .foregroundColor(.red)
            .position(like.position)
            .opacity(like.isAnimated ? 0 : 1)
            .scaleEffect(like.isAnimated ? 0.4 : 1)
    }
}

// MARK: - Preference Key for Scroll Position
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
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
