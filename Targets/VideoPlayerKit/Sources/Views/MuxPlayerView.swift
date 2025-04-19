import SwiftUI
import MuxPlayerSwift
import SharedKit
import AnalyticsKit

/// A SwiftUI view that wraps the Mux Player
public struct MuxPlayerView: UIViewRepresentable {
    private let player: MuxPlayer
    private let autoPlay: Bool
    private let isMuted: Bool
    private let metadata: [String: Any]
    
    /// Initialize a new MuxPlayerView
    /// - Parameters:
    ///   - playbackId: The Mux playback ID
    ///   - autoPlay: Whether to start playing automatically
    ///   - isMuted: Whether to start muted
    ///   - metadata: Additional metadata for analytics
    public init(
        playbackId: String,
        autoPlay: Bool = true,
        isMuted: Bool = false,
        metadata: [String: Any] = [:]
    ) {
        self.player = VideoPlayer.createPlayer(playbackId: playbackId, metadata: metadata)
        self.autoPlay = autoPlay
        self.isMuted = isMuted
        self.metadata = metadata
    }
    
    public func makeUIView(context: Context) -> MuxPlayerView.UIViewType {
        let playerView = player.view
        playerView.backgroundColor = .black
        
        // Configure initial state
        player.isMuted = isMuted
        
        if autoPlay {
            player.play()
        }
        
        // Track view appearance
        Analytics.capture(
            .info,
            id: "video_view_created",
            longDescription: "[VIDEO] Created video view",
            source: .general,
            properties: metadata
        )
        
        return playerView
    }
    
    public func updateUIView(_ uiView: MuxPlayerView.UIViewType, context: Context) {
        // Handle any view updates if needed
    }
    
    /// Get the underlying MuxPlayer instance
    /// - Returns: The MuxPlayer instance
    public func getPlayer() -> MuxPlayer {
        return player
    }
}

// MARK: - Preview Provider
struct MuxPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MuxPlayerView(
            playbackId: "YOUR_PLAYBACK_ID",
            metadata: [
                "title": "Sample Video",
                "id": "video-123",
                "viewer_id": "user-456"
            ]
        )
    }
} 