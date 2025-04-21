//
//  RewardsView.swift
//  App
//

import SwiftUI
import SharedKit
import InAppPurchaseKit

struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    
    // State variables to track claimed status of hardcoded rewards
    @State private var isLoginClaimed: Bool = false
    @State private var isShareClaimed: Bool = false
    @State private var isPushClaimed: Bool = false
    @State private var isReviewClaimed: Bool = false
    
    // Different reward amounts
    private let loginRewardAmount = 50
    private let standardRewardAmount = 20
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) { // Increased spacing between sections
                // Coin Balance Header - Simplified
                HStack {
                    Text("\(viewModel.coinBalance)")
                        .font(.system(size: 40, weight: .bold)) // Increased size for emphasis
                        .foregroundColor(.primary)
                    Text("Balance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Daily Check-in Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Check-in")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    Text("You've checked in for \(viewModel.currentStreak) day\(viewModel.currentStreak == 1 ? "" : "s")!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 10) {
                        ForEach(viewModel.dailyCheckinDays) { day in
                            DailyCheckinItemView(day: day)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        viewModel.performCheckin()
                    } label: {
                        Text(viewModel.isCheckinAvailable ? "Check-in" : "Checked in for Today")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isCheckinAvailable ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.isCheckinAvailable)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.systemSecondaryBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Membership Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Membership")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        Text("Current Tier: \(viewModel.membershipStatus)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Upgrade") {
                            viewModel.handleMembershipAction() // Call the updated VM function
                        }
                        .buttonStyle(FlatButtonStyle())
                    }
                    
                    Text("Upgrade to unlock unlimited access to all series and ad-free viewing!")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.systemSecondaryBackground)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Earn Rewards Section - Hardcoded
                VStack(alignment: .leading, spacing: 0) {
                    Text("Earn Rewards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // Hardcoded Rows
                    StaticRewardActionRow(iconName: "apple.logo", title: "Login with Apple", description: "+\(loginRewardAmount) Coins", isClaimed: $isLoginClaimed) {
                        print("Login with Apple action triggered")
                        // Add actual Apple Sign In logic here
                        viewModel.claimReward(amount: loginRewardAmount)
                    }
                    Divider().padding(.horizontal)
                    
                    StaticRewardActionRow(iconName: "square.and.arrow.up", title: "Share with friends", description: "+\(standardRewardAmount) Coins", isClaimed: $isShareClaimed) {
                        print("Share action triggered")
                        // Add actual Share Sheet logic here
                        viewModel.claimReward(amount: standardRewardAmount)
                    }
                    Divider().padding(.horizontal)
                    
                    StaticRewardActionRow(iconName: "bell.badge.fill", title: "Turn on push notification", description: "+\(standardRewardAmount) Coins", isClaimed: $isPushClaimed) {
                        print("Push notification action triggered")
                        // Add actual Push Notification enablement logic here
                        viewModel.claimReward(amount: standardRewardAmount)
                    }
                    Divider().padding(.horizontal)
                    
                    StaticRewardActionRow(iconName: "star.fill", title: "Review the app", description: "+\(standardRewardAmount) Coins", isClaimed: $isReviewClaimed) {
                        print("Review action triggered")
                        // Add actual App Store Review logic here (e.g., using StoreKit)
                        viewModel.claimReward(amount: standardRewardAmount)
                    }
                }
                .padding(.vertical)
                
                // Buy Coins Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("COINS")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        CoinPackCard(amount: 100, bonusAmount: 20, price: "$0.99")
                            .onTapGesture {
                                print("Buy 100 (+20) coins pack tapped")
                                // TODO: Initiate purchase via InAppPurchaseKit
                            }
                        
                        CoinPackCard(amount: 300, price: "$3.99")
                            .onTapGesture {
                                print("Buy 300 coins pack tapped")
                                // TODO: Initiate purchase via InAppPurchaseKit
                            }
                        
                        CoinPackCard(amount: 500, bonusAmount: 50, price: "$6.99")
                            .onTapGesture {
                                print("Buy 500 (+50) coins pack tapped")
                                // TODO: Initiate purchase via InAppPurchaseKit
                            }
                        
                        CoinPackCard(amount: 1000, bonusAmount: 150, price: "$12.99")
                            .onTapGesture {
                                print("Buy 1000 (+150) coins pack tapped")
                                // TODO: Initiate purchase via InAppPurchaseKit
                            }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                Spacer(minLength: 32)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// View for each day in the check-in row
struct DailyCheckinItemView: View {
    let day: DailyCheckinDay
    
    var body: some View {
        VStack(spacing: 4) {
            Text("+\(day.rewardAmount)")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(day.status == .upcoming ? .secondary : .primary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(day.status == .available ? Color.yellow.opacity(0.3) : Color.clear)
                .cornerRadius(4)
            
            Image(systemName: iconName(for: day.status))
                .foregroundColor(iconColor(for: day.status))
                .font(.title3)
            
            Text("Day \(day.id)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func iconName(for status: DailyCheckinDay.CheckinStatus) -> String {
        switch status {
        case .checkedIn:
            return "checkmark.circle.fill"
        case .available:
            return "gift.fill"
        case .upcoming:
            return "lock.fill"
        }
    }
    
    private func iconColor(for status: DailyCheckinDay.CheckinStatus) -> Color {
        switch status {
        case .checkedIn:
            return .green
        case .available:
            return .yellow
        case .upcoming:
            return .gray
        }
    }
}

// View for HARDCODED Earn Rewards list items
struct StaticRewardActionRow: View {
    let iconName: String
    let title: String
    let description: String
    @Binding var isClaimed: Bool // Use Binding to update state
    let performAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title3)
                .frame(width: 24)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(isClaimed ? "Claimed" : "Claim", action: {
                if !isClaimed {
                    performAction() // Execute the passed-in action (e.g., show share sheet)
                    isClaimed = true // Mark as claimed after action
                }
            })
            .buttonStyle(FlatButtonStyle(disabled: isClaimed))
        }
        .padding(.horizontal)
        .padding(.vertical, 12) // Increased padding for better spacing
    }
}

// Updated CoinPackCard view for grid layout
struct CoinPackCard: View {
    let amount: Int
    var bonusAmount: Int? = nil
    let price: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "circle.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                
                Text("\(amount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(bonusAmount != nil ? "+ \(bonusAmount!)" : "")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .opacity(bonusAmount != nil ? 1 : 0)
            }
            
            Text(price)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

// Flat Button Style (replacing gradient)
struct FlatButtonStyle: ButtonStyle {
    var disabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                disabled ? Color.gray : (configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .disabled(disabled)
    }
}

// Preview
struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RewardsView()
        }
        .preferredColorScheme(.dark)
    }
} 
