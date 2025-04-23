import Foundation
import AVKit
import MuxPlayerSwift
import SharedKit
import os

/// Wrapper around the Mux Player SDK for video playback
public enum VideoPlayer {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayer")
    
    /// Initialize Mux Player with configuration
    static public func initMuxPlayer() {
        let envKey = try? getPlistEntry("MUX_ENV_KEY", in: "Mux-Info")
        
        guard let envKey else {
            fatalError("ERROR: Couldn't find MUX_ENV_KEY in Mux-Info.plist!")
        }
        
        logger.info("[VIDEO] Initialized Mux Player SDK with env key: \(envKey)")
    }
    
    /// Create a new AVPlayerViewController for a given playback ID
    /// - Parameters:
    ///   - playbackId: The Mux playback ID
    ///   - metadata: Additional metadata for analytics
    /// - Returns: A configured AVPlayerViewController
    static public func createPlayerViewController(
        playbackId: String,
        metadata: [String: Any] = [:]
    ) -> AVPlayerViewController {
        // Create player view controller with playback ID
        let playerViewController = AVPlayerViewController()
        
        // Configure the player with the playback ID
        let player = AVPlayer()
        playerViewController.player = player
        
        // Extract the playback ID if it's a URL
        let cleanPlaybackId = extractPlaybackId(from: playbackId)
        
        // Create URL for the Mux stream
        if let url = URL(string: "https://stream.mux.com/\(cleanPlaybackId).m3u8") {
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
        }
        
        logger.info("[VIDEO] Created player view controller for playback ID: \(cleanPlaybackId)")
        return playerViewController
    }
    
    /// Create a new AVPlayerLayer for a given playback ID
    /// - Parameters:
    ///   - playbackId: The Mux playback ID
    ///   - metadata: Additional metadata for analytics
    /// - Returns: A configured AVPlayerLayer
    static public func createPlayerLayer(
        playbackId: String,
        metadata: [String: Any] = [:]
    ) -> AVPlayerLayer {
        // Create a basic AVPlayerLayer
        let player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        
        // Extract the playback ID if it's a URL
        let cleanPlaybackId = extractPlaybackId(from: playbackId)
        
        // Create URL for the Mux stream
        if let url = URL(string: "https://stream.mux.com/\(cleanPlaybackId).m3u8") {
            logger.info("[VIDEO] Creating player with URL: \(url.absoluteString)")
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
        } else {
            logger.error("[VIDEO] Failed to create URL with playback ID: \(playbackId)")
        }
        
        logger.info("[VIDEO] Created player layer for playback ID: \(cleanPlaybackId)")
        return playerLayer
    }
    
    /// Extract a clean playback ID from a URL or raw ID
    private static func extractPlaybackId(from input: String) -> String {
        // Check if input is already a URL
        if input.contains("https://") || input.contains("http://") {
            // Try to extract ID from URL
            if let url = URL(string: input) {
                // If it's a Mux URL, extract just the ID part
                if let host = url.host, host.contains("mux.com") {
                    let pathComponents = url.pathComponents
                    if pathComponents.count > 1 {
                        // Remove .m3u8 extension if present
                        return pathComponents[1].replacingOccurrences(of: ".m3u8", with: "")
                    }
                }
                
                // If it's not a recognized Mux URL format, try a different approach
                let urlString = url.absoluteString
                if let range = urlString.range(of: "mux.com/") {
                    let idStart = range.upperBound
                    let remainingString = urlString[idStart...]
                    if let endRange = remainingString.range(of: ".m3u8") {
                        return String(remainingString[..<endRange.lowerBound])
                    } else {
                        return String(remainingString)
                    }
                }
            }
            
            // If we couldn't extract from URL, log and return the original
            logger.warning("[VIDEO] Could not extract clean playback ID from URL: \(input)")
            return input
        } else {
            // Not a URL, return as is
            return input
        }
    }
} 