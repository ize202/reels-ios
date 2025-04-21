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

    @Published var coinBalance: Int = 20
    @Published var currentStreak: Int = 0 // Start with 0 streak
    @Published var dailyCheckinDays: [DailyCheckinDay] = []
    @Published var isCheckinAvailable: Bool = false
    @Published var membershipStatus: String = "Free Tier"

    private var cancellables = Set<AnyCancellable>()

    // Hardcoded reward amounts for each day
    private let dailyRewards = [20, 20, 40, 20, 20, 50, 80]

    init() {
        setupInitialCheckinState()
    }

    // Initialize with hardcoded state (Day 1 available)
    func setupInitialCheckinState() {
        self.currentStreak = 0 // Or load from persistence later
        self.dailyCheckinDays = (1...7).map { dayNumber in
            let status: DailyCheckinDay.CheckinStatus = (dayNumber == 1) ? .available : .upcoming
            return DailyCheckinDay(id: dayNumber, rewardAmount: dailyRewards[dayNumber - 1], status: status)
        }
        self.isCheckinAvailable = self.dailyCheckinDays.contains { $0.status == .available }
    }

    // --- Actions --- 

    func performCheckin() {
        guard let todayIndex = dailyCheckinDays.firstIndex(where: { $0.status == .available }) else { return }

        // Use the hardcoded reward amount for the specific day
        let rewardAmount = dailyCheckinDays[todayIndex].rewardAmount
        claimReward(amount: rewardAmount)
        currentStreak += 1 // Increment streak

        // Update the checked-in day's status
        dailyCheckinDays[todayIndex].status = .checkedIn

        // Make the next day available, if it exists
        let nextDayId = currentStreak + 1
        if let nextDayIndex = dailyCheckinDays.firstIndex(where: { $0.id == nextDayId }) {
            dailyCheckinDays[nextDayIndex].status = .available
        }

        // Update the check-in availability state
        isCheckinAvailable = dailyCheckinDays.contains { $0.status == .available }
        print("Checked in for Day \(currentStreak)! Earned \(rewardAmount) coins. New balance: \(coinBalance)")
        
        // In a real app: Save currentStreak and dailyCheckinDays state to persistence
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