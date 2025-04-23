import SwiftUI
import AVKit
import SharedKit
import VideoPlayerKit
import SupabaseKit // Assuming FeedItem comes from here or SharedKit

struct FeedPlayerCell: View {
    let item: FeedItem
    let size: CGSize // Pass geometry size from FeedView
    let safeArea: EdgeInsets // Pass safe area from FeedView

    // === Player State ===
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false

    // === Interaction State (Local for feedback) ===
    @State private var isLiked: Bool
    @State private var isSaved: Bool

    // === Overlay Controls State ===
    @State private var showOverlayControls: Bool = true
    @State private var overlayAutoHideTimer: Timer? = nil

    // Initializer to set local state from the item
    init(item: FeedItem, size: CGSize, safeArea: EdgeInsets) {
        self.item = item
        self.size = size
        self.safeArea = safeArea
        // Initialize local state based on the passed item
        _isLiked = State(initialValue: item.isLiked)
        _isSaved = State(initialValue: item.isSaved)
    }

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .scrollView(axis: .vertical))
            
            ZStack {
                // --- Player View ---
                MuxPlayerView(
                    playbackId: item.playbackId,
                    isMuted: false, // Assuming we removed the mute button, default to unmuted
                    player: $player,
                    onTap: handleTap,
                    safeArea: safeArea, // Pass safe area down
                    showScrubber: $showOverlayControls // Pass binding
                )
                .onChange(of: isPlaying) { _, shouldPlay in
                    // Manage player playback
                    if shouldPlay { player?.play() } else { player?.pause() }
                    
                    // Manage overlay visibility
                    if shouldPlay {
                        startAutoHideTimer()
                    } else {
                        cancelAutoHideTimer()
                        showOverlayControls = true // Show controls when paused
                    }
                }

                // --- Side Action Buttons (Aligned Right) ---
                if showOverlayControls {
                    HStack {
                        Spacer() // Pushes the VStack to the right

                        VStack {
                            Spacer()
                                .frame(height: geo.size.height * 0.45)
                            
                            VStack(spacing: 16) {
                                // Like Button
                                Button { 
                                    isLiked.toggle()
                                    // TODO: Call viewModel method here later
                                } label: {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 32))
                                        .foregroundColor(isLiked ? .red : .white)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                        .scaleEffect(isLiked ? 1.1 : 1.0) // Scale animation on state change
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked) // Animate the scale
                                }

                                // Save Button
                                Button { 
                                    isSaved.toggle()
                                    // TODO: Call viewModel method here later
                                } label: {
                                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 32))
                                        .foregroundColor(isSaved ? Color(hex: "9B79C1") : .white)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                        .scaleEffect(isSaved ? 1.1 : 1.0) // Scale animation on state change
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSaved) // Animate the scale
                                }
                            }
                            .padding(.trailing, 16)
                            
                            Spacer()
                        }
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 0.3))) // Fade transition
                    .allowsHitTesting(true)
                }
            }
            .preference(key: OffsetKey.self, value: rect)
            .onPreferenceChange(OffsetKey.self) { value in
                let isCentered = -value.minY < (value.height * 0.5) && value.minY < (value.height * 0.5)
                if isPlaying != isCentered { isPlaying = isCentered }
            }
            .onAppear {
                print("[CELL] Appear: \(item.id)")
                if player == nil { player = MuxVideoPlayer.createPlayer(playbackId: item.playbackId) }
                // Re-sync local state in case the item changed (e.g., refresh)
                isLiked = item.isLiked
                isSaved = item.isSaved
            }
            .onDisappear {
                print("[CELL] Disappear: \(item.id)")
                player?.pause()
                player = nil
                isPlaying = false
                cancelAutoHideTimer() // Cancel timer on disappear
            }
            .id(item.id)
        }
    }

    private func togglePlayPause() {
        guard let player = player else { return }
        if player.rate == 0 { player.play(); isPlaying = true } // isPlaying change triggers timer
        else { player.pause(); isPlaying = false } // isPlaying change shows controls
    }

    private func handleTap() {
        // Always cancel timer and show controls on tap
        cancelAutoHideTimer()
        showOverlayControls = true
        
        // Toggle playback
        togglePlayPause()
        
        // Restart timer ONLY if playback will be active after the toggle
        if player?.rate == 0 { // If player is now playing (was paused)
            startAutoHideTimer()
        }
    }

    // MARK: - Overlay Auto-Hide Timer
    
    private func startAutoHideTimer() {
        // Cancel any existing timer
        cancelAutoHideTimer()
        
        // Schedule a new timer
        overlayAutoHideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            // Only hide if it's still playing
            if isPlaying {
                showOverlayControls = false
                print("[CELL] Auto-hiding overlay for \(item.id)")
            }
        }
        print("[CELL] Started auto-hide timer for \(item.id)")
    }
    
    private func cancelAutoHideTimer() {
        overlayAutoHideTimer?.invalidate()
        overlayAutoHideTimer = nil
        print("[CELL] Cancelled auto-hide timer for \(item.id)")
    }
}

// MARK: - Preference Key (Can likely be reused from FeedView or moved to SharedKit)
// struct OffsetKey: PreferenceKey { ... } - Assuming it exists elsewhere 