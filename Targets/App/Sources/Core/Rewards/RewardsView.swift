//
//  RewardsView.swift
//  App
//

import SwiftUI
import SharedKit
import InAppPurchaseKit

struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    
    // Define the gradient used for buttons (Use AccentColor or standard system colors)
    let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue, Color.purple]), // Example: Standard blue/purple
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Coin Balance Header
                HStack {
                    Text("\(viewModel.coinBalance)")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary) // Use primary for main text
                    Image(systemName: "ticket.fill") // Changed icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.yellow) // Keep yellow for coins/rewards accent
                    Text("Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Use secondary for less important text
                    Spacer()
                    Button("Rules") {
                        print("Rules tapped")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Daily Check-in Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("You've checked in for \(viewModel.currentStreak) day\(viewModel.currentStreak == 1 ? "" : "s")!")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // Daily Check-in Row
                    HStack(spacing: 10) {
                        ForEach(viewModel.dailyCheckinDays) { day in
                            DailyCheckinItemView(day: day)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity) // Ensure HStack takes full width
                    
                    // Check-in Button
                    Button {
                        viewModel.performCheckin()
                    } label: {
                        Text(viewModel.isCheckinAvailable ? "Check-in" : "Checked in for Today")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isCheckinAvailable ? buttonGradient : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.isCheckinAvailable)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.systemSecondaryBackground) // Use adaptive background
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Membership Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Membership")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow) // Keep yellow for VIP/Crown
                        Text("Current Tier: \(viewModel.membershipStatus)")
                            .font(.subheadline)
                            .foregroundColor(.primary) // Use primary
                        Spacer()
                        Button("Upgrade") {
                            print("Upgrade membership tapped")
                            // Placeholder action remains
                            viewModel.handleRewardAction(actionId: viewModel.rewardActions.first(where: {$0.actionType == .membership})?.id ?? UUID())
                        }
                        .buttonStyle(GradientButtonStyle(gradient: buttonGradient, disabled: false))
                    }
                    
                    Text("Unlock exclusive series and enjoy ad-free viewing!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.systemSecondaryBackground) // Use adaptive background
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Earn Rewards Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Earn Rewards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding([.horizontal, .top])
                        .padding(.bottom, 5)
                    
                    // List of Reward Actions
                    ForEach(viewModel.rewardActions) { action in
                        RewardActionRow(action: action, buttonGradient: buttonGradient) {
                            viewModel.handleRewardAction(actionId: action.id)
                        }
                        Divider().padding(.leading, 50) // Indent divider
                    }
                }
                
                Spacer() // Push content to top
            }
        }
        .background(Color.black.ignoresSafeArea()) 
        .preferredColorScheme(.dark) // Keep forcing dark mode
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// View for each day in the check-in row - UPDATED ICONS/COLORS
struct DailyCheckinItemView: View {
    let day: DailyCheckinDay
    
    var body: some View {
        VStack(spacing: 4) {
            Text("+\(day.rewardAmount)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(day.status == .upcoming ? .secondary : .primary) // Dim upcoming text
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(day.status == .available ? Color.yellow.opacity(0.3) : Color.clear)
                .cornerRadius(4)
            
            Image(systemName: iconName(for: day.status)) // Use helper for icon
                .foregroundColor(iconColor(for: day.status)) // Use helper for color
                .font(.title3)
            
            Text("Day \(day.id)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity) // Distribute space evenly
    }
    
    // Helper for icon name based on status
    private func iconName(for status: DailyCheckinDay.CheckinStatus) -> String {
        switch status {
        case .checkedIn:
            return "checkmark.circle.fill"
        case .available:
            return "gift.fill" // Changed to gift
        case .upcoming:
            return "lock.fill" // Changed to lock
        }
    }
    
    // Helper for icon color based on status
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

// View for each row in the Earn Rewards list
struct RewardActionRow: View {
    let action: RewardAction
    let buttonGradient: LinearGradient
    let performAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: action.iconName)
                .font(.title2)
                .frame(width: 25)
                .foregroundColor(.secondary) // Use secondary for icon tint
            
            VStack(alignment: .leading, spacing: 2) {
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary) // Use primary
                HStack(spacing: 4) {
                    Text(action.description)
                        .font(.caption)
                        .foregroundColor(.secondary) // Use secondary
                }
            }
            
            Spacer()
            
            Button(action.buttonLabel, action: performAction)
                .buttonStyle(GradientButtonStyle(gradient: buttonGradient, disabled: action.isButtonDisabled))
                .font(.caption)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}

// Reusable Button Style
struct GradientButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    var disabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                gradient
                .opacity(disabled || configuration.isPressed ? 0.6 : 1.0) // Dim if disabled or pressed
            )
            .cornerRadius(20) // Pill shape
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .disabled(disabled)
    }
}

// Preview
struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        // Embed in NavigationView for previewing title
        NavigationView {
            RewardsView()
        }
        .preferredColorScheme(.dark)
    }
} 
