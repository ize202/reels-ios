import Foundation
import AVKit
import MuxPlayerSwift
import SharedKit
import os

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
    
    /// Create a player with a Mux playback ID or URL
    /// - Parameter playbackId: The Mux playback ID or URL
    /// - Returns: Configured AVPlayer
    static public func createPlayer(playbackId: String) -> AVPlayer {
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
        
        return player
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