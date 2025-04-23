import SwiftUI
import AVKit
import MuxPlayerSwift
import SharedKit
import AnalyticsKit
import Combine // Import Combine for timer publisher

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
    // Safe area for positioning
    private let safeArea: EdgeInsets

    // === Scrubbing State ===
    @State private var currentTime: Double = 0.0
    @State private var duration: Double = 0.0
    @State private var isScrubbing: Bool = false
    @State private var timeObserverToken: Any? // To store the periodic time observer
    @State private var durationObservation: NSKeyValueObservation? // To observe duration
    @State private var wasPlayingBeforeScrub: Bool = false // Track state before scrubbing

    public init(
        playbackId: String,
        // autoPlay: Bool = false, // REMOVED
        isMuted: Bool = false,
        player: Binding<AVPlayer?>,
        metadata: [String: Any] = [:],
        onTap: @escaping () -> Void,
        safeArea: EdgeInsets // Add safeArea parameter
    ) {
        print("[VIDEO] Initializing player wrapper for: \(playbackId)")
        self.playbackId = playbackId
        self.isMuted = isMuted
        self._player = player
        self.onTap = onTap
        self.safeArea = safeArea // Store safeArea
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
                .opacity(player?.rate == 0 && !isScrubbing ? 1 : 0) // Hide pause icon while scrubbing
                .animation(.easeInOut(duration: 0.2), value: player?.rate == 0 && !isScrubbing)
                .allowsHitTesting(false)

            // --- Scrubber ---
            VStack {
                Spacer() // Pushes slider to the bottom
                if duration > 0 { // Only show slider if duration is known
                    Slider(
                        value: $currentTime,
                        in: 0...duration,
                        onEditingChanged: sliderEditingChanged
                    )
                    .tint(Color(hex: "9B79C1")) // Use primary color for the slider track
                    .padding(.horizontal)
                    
                    // Time Labels
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                    // Apply bottom padding here to include labels
                    .padding(.bottom, safeArea.bottom > 0 ? safeArea.bottom : 10) // Ensure minimum padding even without safe area
                }
            }
            .allowsHitTesting(true) // Ensure slider container is interactive
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
             addTimeObserver()
             addDurationObserver()

             // Playback is now fully controlled externally
        }
        .onDisappear {
             print("[VIDEO] MuxPlayerView onDisappear for \(playbackId)")
             removeTimeObserver()
             removeDurationObserver()
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
        .onChange(of: currentTime) { _, newValue in
             // Seek while scrubbing
             if isScrubbing {
                 seek(to: newValue)
             }
        }
        // Use playbackId to recreate the view AND player state when it changes
        // This helps if the same view instance is reused for different videos
        .id(playbackId)
    }

   // REMOVE private func togglePlayPause()

    // MARK: - Time Observation & Scrubbing

    private func addTimeObserver() {
        guard let player = player, timeObserverToken == nil else { return }
        
        // Update time every 0.1 seconds
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak player] time in
            guard let currentItem = player?.currentItem else { return }
            // Only update currentTime if not currently scrubbing
            if !isScrubbing, currentItem.status == .readyToPlay {
                let newTime = CMTimeGetSeconds(time)
                // Only update if the change is significant enough to avoid excessive redraws
                if abs(newTime - currentTime) > 0.05 {
                    self.currentTime = newTime
                }
                // Update duration here as well, in case it becomes available later
                if self.duration == 0 && CMTimeGetSeconds(currentItem.duration).isFinite {
                     self.duration = CMTimeGetSeconds(currentItem.duration)
                     print("[VIDEO] Duration updated via time observer: \(self.duration)")
                }
            }
        }
        print("[VIDEO] Added time observer for \(playbackId)")
    }

    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
            print("[VIDEO] Removed time observer for \(playbackId)")
        }
    }
    
    private func addDurationObserver() {
        guard let player = player, durationObservation == nil, let item = player.currentItem else { return }
        durationObservation = item.observe(\.duration, options: [.new, .initial]) { item, _ in
            guard item.status == .readyToPlay else { return }
            let newDuration = CMTimeGetSeconds(item.duration)
            if newDuration.isFinite, newDuration > 0, self.duration != newDuration {
                DispatchQueue.main.async { // Ensure update on main thread
                    self.duration = newDuration
                    print("[VIDEO] Duration observer updated duration: \(self.duration)")
                }
            }
        }
        print("[VIDEO] Added duration observer for \(playbackId)")
    }

    private func removeDurationObserver() {
        durationObservation?.invalidate()
        durationObservation = nil
        print("[VIDEO] Removed duration observer for \(playbackId)")
    }

    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            self.wasPlayingBeforeScrub = (player?.rate ?? 0) > 0
            player?.pause() // Pause updates during scrub start
            isScrubbing = true
            print("[VIDEO] Scrubbing started. Was playing: \(wasPlayingBeforeScrub)")
        } else {
            // Seek to final position first
            seek(to: currentTime) {
                 // Then update scrubbing state and potentially resume playback
                 self.isScrubbing = false
                 if self.wasPlayingBeforeScrub {
                     self.player?.play()
                     print("[VIDEO] Scrubbing finished. Resuming playback.")
                 } else {
                     print("[VIDEO] Scrubbing finished. Player remains paused.")
                 }
            }
        }
    }

    private func seek(to time: Double, completion: (() -> Void)? = nil) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        print("[VIDEO] Seeking to \(time)")
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
            print("[VIDEO] Seek finished: \(finished)")
            completion?()
        }
    }

    // MARK: - Time Formatting Helper

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "00:00" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// Helper extension for hex color (if not already in SharedKit)
// extension Color { ... } // Assuming it exists or add it to SharedKit
