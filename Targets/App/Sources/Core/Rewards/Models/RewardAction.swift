import Foundation
import SwiftUI // Needed for Identifiable potentially later, or View elements like Icons if used directly

// Represents the type of reward action (used for potential future logic)
enum RewardActionType {
    case loginApple
    case share
    case pushNotification
    case reviewApp
}

// Model for the static "Earn Rewards" items
struct StaticRewardAction: Identifiable {
    let id = UUID() // Unique identifier for each action
    let type: RewardActionType
    let iconName: String
    let title: String
    let descriptionFormat: String // e.g., "+%d Coins"
    let rewardAmount: Int
    var isClaimed: Bool = false // State managed by ViewModel

    // Computed property for the display description
    var description: String {
        String(format: descriptionFormat, rewardAmount)
    }
}

// Note: The full RewardAction struct and ActionStatus might be removed
// if all state is managed directly within RewardsView.
// For now, we keep the type enum.

/* --- Removed original RewardAction struct ---
struct RewardAction: Identifiable { ... }
*/ 