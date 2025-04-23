import SwiftUI
import AVKit
import MuxPlayerSwift
import SharedKit
import AnalyticsKit

/// A SwiftUI view for Mux video playback using a custom player controller
public struct MuxPlayerView: View {
    // Use optional player for CustomVideoPlayer representable
    @State private var player: AVPlayer?
    // Track playback state
    @State private var isPlaying: Bool = false
    // Show/hide the pause icon briefly on tap
    @State private var showPauseIcon: Bool = false

    private let playbackId: String
    private let autoPlay: Bool
    private let isMuted: Bool
    
    /// Initialize a new MuxPlayerView
    /// - Parameters:
    ///   - playbackId: The Mux playback ID or URL
    ///   - autoPlay: Whether to start playing automatically
    ///   - isMuted: Whether to start muted
    ///   - metadata: Additional metadata for analytics (not used in simplified version)
    public init(
        playbackId: String,
        autoPlay: Bool = true,
        isMuted: Bool = false,
        metadata: [String: Any] = [:]
    ) {
        print("[VIDEO] Initializing player wrapper for: \(playbackId)")
        self.playbackId = playbackId
        // Initialize player within the init or onAppear
        self._player = State(initialValue: nil)
        self.autoPlay = autoPlay
        self.isMuted = isMuted
        // isPlaying state should align with autoPlay initially
        self._isPlaying = State(initialValue: autoPlay)
    }
    
    public var body: some View {
        ZStack {
            // Custom Player View
            if let player = player {
                CustomVideoPlayer(player: .constant(player))
            } else {
                // Placeholder or loading view while player initializes
                Color.black
                    .overlay(ProgressView().tint(.white))
            }

            // Play/Pause Overlay Icon
            Image(systemName: "pause.fill")
                .font(.system(size: 45))
                .foregroundColor(.white.opacity(0.8))
                .padding(20)
                .background(.black.opacity(0.3))
                .clipShape(Circle())
                .opacity(showPauseIcon ? 1 : 0) // Show only when tapped
                .allowsHitTesting(false) // Don't interfere with tap gesture below
        }
        .contentShape(Rectangle()) // Ensure the whole area is tappable
        .onTapGesture {
            togglePlayPause()
        }
        .onAppear {
            // Initialize player only if it hasn't been created yet
            if player == nil {
                print("[VIDEO] Creating player onAppear for: \(playbackId)")
                player = MuxVideoPlayer.createPlayer(playbackId: playbackId)
            }
            
            guard let player = player else { return }
            
            // Configure player
            player.isMuted = isMuted
            
            // Reset player state if needed (e.g., re-appearing)
            // Consider if seeking to zero is always desired on appear
            // player.seek(to: .zero)
            
            // Handle autoplay
            if autoPlay && !isPlaying {
                player.play()
                isPlaying = true
                print("[VIDEO] Auto-playing video")
            } else if !autoPlay && isPlaying {
                 // Ensure consistency if autoplay is off but state is playing
                 player.pause()
                 isPlaying = false
            }
        }
        .onDisappear {
            // Pause when view disappears
            print("[VIDEO] Pausing video onDisappear")
            player?.pause()
            isPlaying = false
            // Optionally reset player to nil to free resources if view is destroyed
            // player = nil
        }
        .onChange(of: isMuted) { newValue in
             print("[VIDEO] Setting muted state: \(newValue)")
            player?.isMuted = newValue
        }
        // Use playbackId to recreate the view AND player state when it changes
        .id(playbackId)
    }

    private func togglePlayPause() {
        guard let player = player else { return }
        
        isPlaying.toggle()
        
        if isPlaying {
            print("[VIDEO] Playing via tap")
            player.play()
            // Hide pause icon immediately after resuming play
            showPauseIcon = false
        } else {
            print("[VIDEO] Pausing via tap")
            player.pause()
            // Show pause icon briefly
            showPauseIcon = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showPauseIcon = false
            }
        }
    }
}
