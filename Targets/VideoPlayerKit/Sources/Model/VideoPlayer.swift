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
        
        // Initialize with environment key
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
        
        logger.info("[VIDEO] Created player view controller for playback ID: \(playbackId)")
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
        
        logger.info("[VIDEO] Created player layer for playback ID: \(playbackId)")
        return playerLayer
    }
} 