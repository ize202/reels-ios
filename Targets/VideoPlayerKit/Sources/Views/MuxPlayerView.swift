import SwiftUI
import AVKit
import MuxPlayerSwift
import SharedKit
import AnalyticsKit

/// A SwiftUI view for Mux video playback using SwiftUI's VideoPlayer
public struct MuxPlayerView: View {
    @State private var player: AVPlayer
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
        print("[VIDEO] Creating player for: \(playbackId)")
        self.playbackId = playbackId
        self._player = State(initialValue: MuxVideoPlayer.createPlayer(playbackId: playbackId))
        self.autoPlay = autoPlay
        self.isMuted = isMuted
    }
    
    public var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                // Configure player
                player.isMuted = isMuted
                
                // Reset player state just in case
                player.seek(to: .zero)
                
                // Force play on appear if autoPlay is enabled
                if autoPlay {
                    player.play()
                    print("[VIDEO] Playing video")
                }
            }
            .onDisappear {
                // Pause and reset when view disappears
                player.pause()
                
                // Clear any observers/notifications here if needed
            }
            .onChange(of: isMuted) { newValue in
                player.isMuted = newValue
            }
            .id(playbackId) // Force view to recreate when playbackId changes
    }
}

// MARK: - Preview Provider
struct MuxPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MuxPlayerView(
            playbackId: "YOUR_PLAYBACK_ID"
        )
    }
} 
