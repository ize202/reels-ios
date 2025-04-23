import SwiftUI
import AVKit
import MuxPlayerSwift
import SharedKit
import AnalyticsKit

/// A SwiftUI view for Mux video playback using a custom player controller.
/// Playback (play/pause) is controlled externally based on scroll visibility.
public struct MuxPlayerView: View {
    // Expose the player instance for external control
    @Binding var player: AVPlayer?
    // Store the player instance created locally - REMOVED
    // REMOVED: @State private var internalPlayerInstance: AVPlayer?

    private let playbackId: String
    // REMOVE: private let autoPlay: Bool
    private let isMuted: Bool
    // Callback for tap gestures
    private let onTap: () -> Void
    
    public init(
        playbackId: String,
        // autoPlay: Bool = false, // REMOVED
        isMuted: Bool = false,
        player: Binding<AVPlayer?>,
        metadata: [String: Any] = [:],
        onTap: @escaping () -> Void // Add callback
    ) {
        print("[VIDEO] Initializing player wrapper for: \(playbackId)")
        self.playbackId = playbackId
        self.isMuted = isMuted
        self._player = player // Connect binding
        self.onTap = onTap
    }
    
    public var body: some View {
        ZStack {
            // Custom Player View - Use binding directly
            if let player = player { // Use the binding directly
                CustomVideoPlayer(player: .constant(player))
                    .allowsHitTesting(false) // Make player view non-interactive for tap gesture
            } else {
                // Placeholder or loading view while player initializes
                Color.black
                    .overlay(ProgressView().tint(.white))
            }

            // Transparent overlay for tap gesture
            Color.clear
                .contentShape(Rectangle()) // Ensure the whole area is tappable
                .onTapGesture {
                    print("[VIDEO] Tap detected on MuxPlayerView for \(playbackId)")
                    // Call the external toggle function
                    onTap()
                }

            // Play/Pause Overlay Icon (controlled by external state via player rate)
            Image(systemName: "pause.fill")
                .font(.system(size: 45))
                .foregroundColor(.white.opacity(0.8))
                .padding(20)
                .background(.black.opacity(0.3))
                .clipShape(Circle())
                // Show icon only if player is paused (rate is 0) - Use binding
                .opacity(player?.rate == 0 ? 1 : 0)
                .allowsHitTesting(false) 
        }
        .onAppear {
             print("[VIDEO] MuxPlayerView onAppear for \(playbackId)")
            // REMOVED: Player creation is now handled by the parent view (FeedPlayerCell)
            // REMOVED: if player == nil {
            // REMOVED:     print("[VIDEO] Creating player onAppear for: \(playbackId)")
            // REMOVED:     let newPlayer = MuxVideoPlayer.createPlayer(playbackId: playbackId)
            // REMOVED:     DispatchQueue.main.async { // Ensure update happens after view cycle
            // REMOVED:         self.player = newPlayer
            // REMOVED:      }
            // REMOVED: }
            
             // Configure player - Apply to binding if player exists
             player?.isMuted = isMuted
             
             // Playback is now fully controlled externally
        }
        .onDisappear {
             print("[VIDEO] MuxPlayerView onDisappear for \(playbackId)")
            // External view (FeedView) is responsible for pausing and managing player lifecycle
            // We might not want to pause here directly, as it might be just temporarily offscreen
            // internalPlayerInstance?.pause()
            // Setting player binding to nil might be desired if the view is truly gone
            // player = nil 
            // internalPlayerInstance = nil
        }
        .onChange(of: isMuted) { newValue in
             print("[VIDEO] Setting muted state: \(newValue)")
             player?.isMuted = newValue
        }
        // Use playbackId to recreate the view AND player state when it changes
        // This helps if the same view instance is reused for different videos
        .id(playbackId)
    }

   // REMOVE private func togglePlayPause()
}
