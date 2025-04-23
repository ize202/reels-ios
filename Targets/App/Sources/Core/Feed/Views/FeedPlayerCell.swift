import SwiftUI
import AVKit
import SharedKit
import VideoPlayerKit
import SupabaseKit // Assuming FeedItem comes from here or SharedKit

struct FeedPlayerCell: View {
    let item: FeedItem
    let size: CGSize // Pass geometry size from FeedView
    let safeArea: EdgeInsets // Pass safe area from FeedView

    // === Self-Contained State ===
    @State private var player: AVPlayer?
    @State private var isMuted: Bool = false // Default to not muted
    @State private var isPlaying: Bool = false // Track playing state based on visibility

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .scrollView(axis: .vertical))
            
            ZStack {
                // --- Player View ---
                MuxPlayerView(
                    playbackId: item.playbackId,
                    isMuted: isMuted,
                    player: $player, // Pass binding to our local player state
                    onTap: togglePlayPause // Use local toggle function
                )
                .onChange(of: isPlaying) { shouldPlay in
                    // Explicitly control play/pause based on visibility state
                    if shouldPlay {
                        player?.play()
                    } else {
                        player?.pause()
                    }
                }

                // --- Bottom Info/Controls Overlay ---
                VStack {
                    Spacer() // Push content to bottom
                    HStack(alignment: .bottom, spacing: 20) {
                        Spacer() // Remove the title/description VStack, let buttons take full width space initially

                        // Action Buttons
                        VStack(spacing: 24) {
                            // Like Button
                            Button { /* viewModel.toggleLike(item.id) */ } label: {
                                Image(systemName: item.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(item.isLiked ? .red : .white)
                            }

                            // Save Button
                            Button { /* viewModel.toggleSave(item.id) */ } label: {
                                Image(systemName: item.isSaved ? "bookmark.fill" : "bookmark")
                                    .foregroundColor(item.isSaved ? Color(hex: "9B79C1") : .white)
                            }

                            // Remove Mute, Episodes, Share buttons
                        }
                        .font(.system(size: 24)) // Keep font size for remaining icons
                        .foregroundColor(.white)
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, safeArea.bottom + 15) // Use safe area passed from FeedView
                }
                .allowsHitTesting(true) // Ensure overlay buttons are tappable
            }
            .preference(key: OffsetKey.self, value: rect) // Track position
            .onPreferenceChange(OffsetKey.self) { value in
                // Determine if centered and update isPlaying state
                let isCentered = -value.minY < (value.height * 0.5) && value.minY < (value.height * 0.5)
                
                // Only update if the state changes to avoid unnecessary redraws/player commands
                if isPlaying != isCentered {
                     print("[CELL] Item \(item.id) centered: \(isCentered)")
                     isPlaying = isCentered
                }
            }
            .onAppear {
                print("[CELL] FeedPlayerCell appeared for item: \(item.id)")
                // Create player only if it doesn't exist
                if player == nil {
                     print("[CELL] Creating player for item: \(item.id)")
                    player = MuxVideoPlayer.createPlayer(playbackId: item.playbackId)
                    player?.isMuted = isMuted // Apply initial mute state
                    // Player will be started by the isPlaying state change if needed
                }
            }
            .onDisappear {
                 print("[CELL] FeedPlayerCell disappeared for item: \(item.id)")
                // Pause and release player when view is fully gone
                player?.pause()
                player = nil
                isPlaying = false // Reset playing state
            }
            .id(item.id) // Ensure ZStack identifies with item
        }
    }

    // MARK: - Local Control Functions

    /// Toggles play/pause state locally for this cell's player
    private func togglePlayPause() {
        guard let player = player else { return }
        if player.rate == 0 {
            print("[CELL] Tapped to play item: \(item.id)")
            player.play()
            isPlaying = true // Keep isPlaying state consistent
        } else {
             print("[CELL] Tapped to pause item: \(item.id)")
            player.pause()
            isPlaying = false // Keep isPlaying state consistent
        }
    }
}

// MARK: - Preference Key (Can likely be reused from FeedView or moved to SharedKit)
// struct OffsetKey: PreferenceKey { ... } - Assuming it exists elsewhere 