import Foundation

// Represents a single action a user can take to earn rewards
struct RewardAction: Identifiable {
    let id = UUID()
    let title: String
    let description: String // e.g., "+40 Reward coins" or "Watch a video to earn 20 coins"
    let iconName: String // SF Symbol name
    let actionType: ActionType
    var status: ActionStatus = .available // Default status
    // var progress: Progress? = nil // Optional progress for multi-step actions - REMOVED for now

    enum ActionType {
        case socialFollow // YouTube, Instagram, etc.
        case share
        case pushNotification
        case login
        case checkIn // For daily check-in specific reward, if any besides the main one
        case membership // Action related to viewing/upgrading membership
        case claimed // For single-claim actions like push notifications
    }

    enum ActionStatus {
        case available // Can be actioned
        case inProgress // For multi-step actions like watch ads/time
        case completed // Already done, reward claimed
        case claimed // For single-claim actions like push notifications
    }

    // Optional struct for tracking progress - REMOVED for now
    /*
    struct Progress {
        let current: Int
        let target: Int
        var description: String { // Example: "(0/15)"
            "(\(current)/\(target))"
        }
    }
    */

    // Convenience properties for button labels based on type and status
    var buttonLabel: String {
        switch status {
        case .claimed, .completed:
            return "Claimed" // Or "Completed" maybe?
        case .inProgress:
            return "Continue" // Or show progress like "Watch"
        case .available:
            switch actionType {
            case .socialFollow, .login, .share, .membership:
                return "Go"
            case .pushNotification, .checkIn, .claimed:
                return "Claim"
            }
        }
    }

    var isButtonDisabled: Bool {
        return status == .claimed || status == .completed
    }
} 