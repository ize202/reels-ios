import Foundation

// Represents the type of reward action (used for potential future logic)
enum RewardActionType {
    case loginApple
    case share
    case pushNotification
    case reviewApp
}

// Note: The full RewardAction struct and ActionStatus might be removed
// if all state is managed directly within RewardsView.
// For now, we keep the type enum.

/* --- Removed original RewardAction struct ---
struct RewardAction: Identifiable { ... }
*/ 