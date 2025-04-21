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

        // --- Mock Reward Actions REMOVED --- 
        // self.rewardActions = [ ... ]
    }

    // --- Actions --- 

    func performCheckin() {
        guard let todayIndex = dailyCheckinDays.firstIndex(where: { $0.status == .available }) else { return }

        let rewardAmount = dailyCheckinDays[todayIndex].rewardAmount
        claimReward(amount: rewardAmount) // Use claimReward
        currentStreak += 1

        dailyCheckinDays[todayIndex].status = .checkedIn
        if let nextDayIndex = dailyCheckinDays.firstIndex(where: { $0.id == currentStreak + 1 }) {
            dailyCheckinDays[nextDayIndex].status = .available
        }
        isCheckinAvailable = false
        print("Checked in for Day \(currentStreak)! Earned \(rewardAmount) coins. New balance: \(coinBalance)")
    }
    
    // Simple function to add coins
    func claimReward(amount: Int) {
        guard amount > 0 else { return }
        coinBalance += amount
        print("Claimed \(amount) coins. New balance: \(coinBalance)")
    }

    // Placeholder for membership action - Keep simple logic if needed for navigation
    func handleMembershipAction() {
        print("Navigate to Membership/Upgrade screen")
        // Add actual navigation logic here later
    }
} 