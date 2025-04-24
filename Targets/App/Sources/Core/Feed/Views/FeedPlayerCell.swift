import SwiftUI
import AVKit
import SharedKit
import VideoPlayerKit
import SupabaseKit // Assuming FeedItem comes from here or SharedKit
import InAppPurchaseKit // <-- Import InAppPurchaseKit

struct FeedPlayerCell: View {
    let item: FeedItem
    let size: CGSize // Pass geometry size from FeedView
    let safeArea: EdgeInsets // Pass safe area from FeedView

    // === Player State ===
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false

    // === Overlay Controls State ===
    @State private var showOverlayControls: Bool = true
    @State private var overlayAutoHideTimer: Timer? = nil

    // === In-App Purchase State ===
    @EnvironmentObject var iap: InAppPurchases // <-- Add EnvironmentObject

    // Initializer: Remove isLiked/isSaved initialization
    init(item: FeedItem, size: CGSize, safeArea: EdgeInsets) {
        self.item = item
        self.size = size
        self.safeArea = safeArea
        // Removed: _isLiked = State(initialValue: item.isLiked)
        // Removed: _isSaved = State(initialValue: item.isSaved)
    }

    var body: some View {
        // === VIP Gating Check ===
        if item.unlockType == .vip && iap.subscriptionState == .notSubscribed && !isPreview { // Compare with enum case .vip
             VipLockedView() // <-- Show locked view
        } else {
            // === Existing Player View ===
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
                }
                .preference(key: OffsetKey.self, value: rect)
                .onPreferenceChange(OffsetKey.self) { value in
                    let isCentered = -value.minY < (value.height * 0.5) && value.minY < (value.height * 0.5)
                    if isPlaying != isCentered { isPlaying = isCentered }
                }
                .onAppear {
                    print("[CELL] Appear: \(item.id)")
                    // Only create player if not VIP-locked
                    if player == nil && !(item.unlockType == .vip && iap.subscriptionState == .notSubscribed) { // Also use enum case here
                         player = MuxVideoPlayer.createPlayer(playbackId: item.playbackId)
                    }
                    // Removed state sync
                    // isLiked = item.isLiked
                    // isSaved = item.isSaved
                }
                .onDisappear {
                    print("[CELL] Disappear: \(item.id)")
                    player?.pause()
                    player = nil // Release player instance fully
                    isPlaying = false
                    cancelAutoHideTimer() // Cancel timer on disappear
                }
                .id(item.id) // Use item ID for view identity
            }
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

// MARK: - VIP Locked View
private struct VipLockedView: View {
    var body: some View {
        ZStack {
            // Background (e.g., blurred thumbnail or solid color)
            Color.black.opacity(0.8) // Dark overlay

            VStack(spacing: 20) {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))

                Text("VIP Episode Locked")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Subscribe to unlock this episode and get unlimited access to all VIP content.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    InAppPurchases.showPaywallSheet() // Trigger paywall
                } label: {
                    Text("Unlock with VIP")
                        .fontWeight(.semibold)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background(Color.accentColor) // Use AccentColor from Assets
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.top)
            }
        }
        .edgesIgnoringSafeArea(.all) // Make sure it covers the whole cell area
    }
}

// MARK: - Preference Key (Can likely be reused from FeedView or moved to SharedKit)
// struct OffsetKey: PreferenceKey { ... } - Assuming it exists elsewhere 