import SwiftUI
import AVKit
import MuxPlayerSwift
import SharedKit
import AnalyticsKit

/// A SwiftUI view that wraps an AVPlayerLayer for Mux video playback
public struct MuxPlayerView: UIViewRepresentable {
    private let playbackId: String
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
        self.playbackId = playbackId
        self.autoPlay = autoPlay
        self.isMuted = isMuted
        self.metadata = metadata
    }
    
    public func makeUIView(context: Context) -> UIView {
        // Create container view
        let containerView = UIView()
        containerView.backgroundColor = .black
        
        // Create player layer
        let playerLayer = VideoPlayer.createPlayerLayer(
            playbackId: playbackId,
            metadata: metadata
        )
        
        // Configure player layer
        playerLayer.videoGravity = .resizeAspectFill
        containerView.layer.addSublayer(playerLayer)
        
        // Configure initial state
        if let player = playerLayer.player {
            player.isMuted = isMuted
            
            // Create URL for the Mux stream
            if let url = URL(string: "https://stream.mux.com/\(playbackId).m3u8") {
                let playerItem = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: playerItem)
                
                if autoPlay {
                    player.play()
                }
            }
        }
        
        // Track view appearance
        Analytics.capture(
            .info,
            id: "video_view_created",
            longDescription: "[VIDEO] Created video view",
            source: .general,
        )
        
        return containerView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure player layer fills the container
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
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
