import Foundation
import AVKit
import MuxPlayerSwift
import MUXSDKStats
import SharedKit
import os

/// Metadata structure for Mux analytics
public struct MuxVideoMetadata {
    public let title: String
    public let series: String?
    public let episodeNumber: String?
    public let contentType: String
    public let videoId: String
    
    public init(
        title: String,
        series: String? = nil,
        episodeNumber: String? = nil,
        contentType: String = "vod",
        videoId: String
    ) {
        self.title = title
        self.series = series
        self.episodeNumber = episodeNumber
        self.contentType = contentType
        self.videoId = videoId
    }
}

/// Wrapper around the Mux Player SDK for video playback
public enum MuxVideoPlayer {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayer")
    
    /// Initialize Mux Player with configuration
    static public func initMuxPlayer() {
        let envKey = try? getPlistEntry("MUX_ENV_KEY", in: "Mux-Info")
        
        guard let envKey else {
            fatalError("ERROR: Couldn't find MUX_ENV_KEY in Mux-Info.plist!")
        }
        
        logger.info("[VIDEO] Initialized Mux Player SDK with env key: \(envKey)")
    }
    
    /// Create a player with a Mux playback ID or URL with optional metadata
    /// - Parameter playbackId: The Mux playback ID or URL
    /// - Parameter metadata: Optional metadata for analytics
    /// - Returns: Configured AVPlayer
    static public func createPlayer(
        playbackId: String,
        metadata: MuxVideoMetadata? = nil
    ) -> AVPlayer {
        // Extract clean ID from either direct ID or URL
        let cleanId = extractPlaybackId(from: playbackId)
        
        // Create URL for the Mux stream
        let url = URL(string: "https://stream.mux.com/\(cleanId).m3u8")!
        logger.info("[VIDEO] Creating player with URL: \(url)")
        
        // Create asset and item with appropriate options for better streaming
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Create player with the item
        let player = AVPlayer(playerItem: playerItem)
        player.volume = 1.0
        
        // Configure automatic playback rate adjustment (if needed)
        player.automaticallyWaitsToMinimizeStalling = true
        
        // Setup Mux Data monitoring
        setupMuxDataMonitoring(player: player, playbackId: cleanId, metadata: metadata)
        
        return player
    }
    
    /// Setup Mux Data monitoring for analytics
    private static func setupMuxDataMonitoring(
        player: AVPlayer,
        playbackId: String,
        metadata: MuxVideoMetadata?
    ) {
        // Data monitoring environment key
        let dataEnvKey = "6vi62d5m621a0902k9j8sdc6d" // Data environment key
        
        // Setup player data
        let playerData = MUXSDKCustomerPlayerData()
        playerData.environmentKey = dataEnvKey
        playerData.playerName = "ReelsApp Player"
        
        // Setup video data
        let videoData = MUXSDKCustomerVideoData()
        videoData.videoId = metadata?.videoId ?? playbackId
        
        // Use provided metadata if available, otherwise use defaults
        if let metadata = metadata {
            videoData.videoTitle = metadata.title
            if let series = metadata.series {
                videoData.videoSeries = series
            }
            if let episodeNumber = metadata.episodeNumber {
                videoData.videoContentType = metadata.contentType
                // videoData.videoSeasonNumber = "1" // ERROR: Property doesn't exist
                // videoData.videoEpisodeNumber = episodeNumber // ERROR: Property doesn't exist
                // Consider adding these as custom dimensions if needed
            }
        } else {
            // Default values if no metadata provided
            videoData.videoTitle = "Episode \(playbackId)"
            videoData.videoSeries = "Reels"
        }
        
        // Create customer data object
        let customerData = MUXSDKCustomerData()
        customerData.customerPlayerData = playerData // Corrected property name
        customerData.customerVideoData = videoData // Corrected property name
        
        // Initialize monitoring for this player
        MUXSDKStats.monitorAVPlayer(
            player,
            withPlayerName: "ReelsApp_\(playbackId)",
            fixedPlayerSize: CGSize(width: 640, height: 360), // Provide a default size
            customerData: customerData
        )
        
        logger.info("[VIDEO] Initialized Mux Data monitoring for playback ID: \(playbackId)")
    }
    
    /// Extract a clean playback ID from a URL or raw ID
    private static func extractPlaybackId(from input: String) -> String {
        // If input contains a URL, extract ID from it
        if input.contains("mux.com") {
            // Try pattern: mux.com/PLAYBACK_ID.m3u8
            if let range = input.range(of: "mux.com/") {
                let idStart = range.upperBound
                let remainingString = input[idStart...]
                if let endRange = remainingString.range(of: ".m3u8") {
                    let id = String(remainingString[..<endRange.lowerBound])
                    logger.info("[VIDEO] Extracted ID \(id) from URL")
                    return id
                }
            }
            
            logger.warning("[VIDEO] Could not extract clean playback ID from URL: \(input)")
            return input
        } else {
            // Already a clean ID
            return input
        }
    }
}
