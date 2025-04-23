import SwiftUI
import AVKit

struct CustomVideoPlayer: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.videoGravity = .resizeAspectFill
        controller.showsPlaybackControls = false
        // Ensure audio continues playing in silent mode and background if needed (adjust as necessary)
        // try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        /// Updating Player
        uiViewController.player = player
    }
} 