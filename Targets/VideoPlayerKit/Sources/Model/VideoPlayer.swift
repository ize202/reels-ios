import Foundation
import SharedKit
import MuxPlayerSwift
import AnalyticsKit
import CrashlyticsKit
import os

/// Wrapper around the Mux Player SDK for video playback
public enum VideoPlayer {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayer")
    
    /// Initialize Mux Player with configuration from Mux-Info.plist
    static public func initMuxPlayer() {
        guard let envKey = try? getPlistEntry("MUX_ENV_KEY", in: "Mux-Info"), !envKey.isEmpty else {
            fatalError("ERROR: Couldn't find MUX_ENV_KEY in Mux-Info.plist!")
        }
        
        MuxSDK.setCustomerData(envKey: envKey)
        
        logger.info("[VIDEO] Initialized Mux Player SDK with env key: \(envKey)")
    }
    
    /// Create a new MuxPlayer instance for a given playback ID
    /// - Parameters:
    ///   - playbackId: The Mux playback ID
    ///   - metadata: Additional metadata for analytics
    /// - Returns: A configured MuxPlayer instance
    static public func createPlayer(
        playbackId: String,
        metadata: [String: Any] = [:]
    ) -> MuxPlayer {
        let player = MuxPlayer()
        player.playbackID = playbackId
        
        // Set up metadata for analytics
        var playerData = PlayerData()
        playerData.environmentKey = try? getPlistEntry("MUX_ENV_KEY", in: "Mux-Info")
        
        var videoData = VideoData()
        if let title = metadata["title"] as? String {
            videoData.videoTitle = title
        }
        if let id = metadata["id"] as? String {
            videoData.videoId = id
        }
        
        var viewData = ViewData()
        if let viewerId = metadata["viewer_id"] as? String {
            viewData.viewerUserId = viewerId
        }
        
        // Monitor for errors
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
            if let error = player.error {
                Crashlytics.captureError(
                    error,
                    extras: [
                        "playback_id": playbackId,
                        "position": time.seconds,
                        "metadata": metadata
                    ]
                )
            }
        }
        
        logger.info("[VIDEO] Created Mux Player instance for playback ID: \(playbackId)")
        
        return player
    }
} 