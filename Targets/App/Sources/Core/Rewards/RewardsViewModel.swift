import Foundation
import Combine
import SwiftUI // Needed for @MainActor

// Model for representing a day in the check-in sequence
struct DailyCheckinDay: Identifiable {
    let id: Int // Day number (1-7)
    let rewardAmount: Int
    var status: CheckinStatus

    enum CheckinStatus {
        case checkedIn // Already claimed for this cycle
        case available // Today's check-in, ready to claim
        case upcoming // Future day
    }
}

@MainActor
class RewardsViewModel: ObservableObject {

    @Published var coinBalance: Int = 28 // Starting balance inspired by screenshot
    @Published var currentStreak: Int = 0 // Example streak
    @Published var dailyCheckinDays: [DailyCheckinDay] = []
    @Published var rewardActions: [RewardAction] = []
    @Published var isCheckinAvailable: Bool = false
    @Published var membershipStatus: String = "Free Tier" // Placeholder

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupMockData()
        // In a real app, fetch data from a service
    }

    func setupMockData() {
        // --- Mock Daily Check-in Data --- 
        // Simulate based on currentStreak
        var days: [DailyCheckinDay] = []
        let rewards = [20, 20, 40, 20, 20, 50, 80] // Example rewards for Day 1-7
        for i in 1...7 {
            let status: DailyCheckinDay.CheckinStatus
            if i <= currentStreak {
                status = .checkedIn
            } else if i == currentStreak + 1 {
                status = .available
            } else {
                status = .upcoming
            }
            days.append(DailyCheckinDay(id: i, rewardAmount: rewards[i-1], status: status))
        }
        self.dailyCheckinDays = days
        self.isCheckinAvailable = days.contains { $0.status == .available }

        // --- Mock Reward Actions --- 
        self.rewardActions = [
            RewardAction(title: "Follow us on YouTube", description: "+40 Reward coins", iconName: "play.rectangle.fill", actionType: .socialFollow),
            RewardAction(title: "Share with friends", description: "+30 Reward coins", iconName: "arrowshape.turn.up.right.fill", actionType: .share),
            RewardAction(title: "Follow us on Instagram", description: "+50 Reward coins", iconName: "camera.fill", actionType: .socialFollow),
            RewardAction(title: "Turn push notification", description: "+20 Reward coins", iconName: "bell.badge.fill", actionType: .pushNotification, status: .claimed), // Example: already claimed
            RewardAction(title: "Login with any account", description: "+60 Reward coins", iconName: "link", actionType: .login)
        ]
    }

    // --- Actions --- 

    func performCheckin() {
        guard let todayIndex = dailyCheckinDays.firstIndex(where: { $0.status == .available }) else { return }

        let rewardAmount = dailyCheckinDays[todayIndex].rewardAmount
        coinBalance += rewardAmount
        currentStreak += 1

        // Update status locally (in real app, update backend then refresh)
        dailyCheckinDays[todayIndex].status = .checkedIn
        if let nextDayIndex = dailyCheckinDays.firstIndex(where: { $0.id == currentStreak + 1 }) {
            dailyCheckinDays[nextDayIndex].status = .available
        }
        isCheckinAvailable = false // Today's check-in is done
        print("Checked in for Day \(currentStreak)! Earned \(rewardAmount) coins. New balance: \(coinBalance)")
    }

    func handleRewardAction(actionId: UUID) {
        guard let index = rewardActions.firstIndex(where: { $0.id == actionId }) else { return }
        let action = rewardActions[index]

        // Don't process if already claimed/completed
        guard !action.isButtonDisabled else {
            print("Action '\(action.title)' already completed/claimed.")
            return
        }

        print("Performing action: \(action.title) (\(action.actionType))")

        // Simulate action & reward - Replace with actual logic later
        var rewardAmount = 0
        var shouldComplete = true // Most actions complete in one step

        switch action.actionType {
        case .socialFollow:
            rewardAmount = Int(action.description.split(separator: " ").first?.dropFirst() ?? "0") ?? 0
            // Add navigation logic here later
        case .share:
            rewardAmount = Int(action.description.split(separator: " ").first?.dropFirst() ?? "0") ?? 0
            // Add share sheet logic here later
        case .pushNotification:
            rewardAmount = Int(action.description.split(separator: " ").first?.dropFirst() ?? "0") ?? 0
            // Add push notification enablement logic here later
            rewardActions[index].status = .claimed // Mark as claimed immediately
        case .login:
            rewardAmount = Int(action.description.split(separator: " ").first?.dropFirst() ?? "0") ?? 0
            // Add login navigation/flow logic here later
        case .checkIn:
            // Handled by performCheckin typically
            break
        case .membership:
            // Add navigation to membership/IAP screen later
            shouldComplete = false // Don't mark as complete just for navigating
            break
        case .claimed:
            // Already claimed, no action needed
            break
        }

        if shouldComplete && action.actionType != .pushNotification {
            // Mark as completed unless it was push (already claimed)
            rewardActions[index].status = .completed
        }

        if rewardAmount > 0 {
            coinBalance += rewardAmount
            print("Action '\(action.title)' completed. Earned \(rewardAmount) coins. New balance: \(coinBalance)")
        }

        // Force UI update
        objectWillChange.send()
    }
} 