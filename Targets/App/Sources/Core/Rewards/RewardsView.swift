//
//  RewardsView.swift
//  App
//

import SwiftUI
import SharedKit
import InAppPurchaseKit

struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    
    // Define the gradient used for buttons
    let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [Color.pink, Color.orange]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Coin Balance Header (Simple version)
                HStack {
                    Text("\(viewModel.coinBalance)")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                    Image(systemName: "bitcoinsign.circle.fill") // Placeholder coin icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.yellow) // Adjust color
                    Text("Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    // Optional: Rules button like in screenshot
                    Button("Rules") {
                        // Action for rules
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
                            .background(viewModel.isCheckinAvailable ? buttonGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                    }
                    .disabled(!viewModel.isCheckinAvailable)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color.systemSecondaryBackground) // Subtle background
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
                            // Action to perform when button is tapped
                            viewModel.handleRewardAction(actionId: action.id)
                        }
                        Divider().padding(.leading, 50) // Indent divider
                    }
                }
                
                // Membership Section (Placeholder)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Membership")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Current Tier: \(viewModel.membershipStatus)")
                            .font(.subheadline)
                        Spacer()
                        Button("Upgrade") {
                            // Navigate to IAP/Membership view
                            print("Upgrade membership tapped")
                            viewModel.handleRewardAction(actionId: viewModel.rewardActions.first(where: {$0.actionType == .membership})?.id ?? UUID()) // Trigger placeholder action
                        }
                        .buttonStyle(GradientButtonStyle(gradient: buttonGradient, disabled: false)) // Use style
                    }
                    
                    Text("Unlock exclusive series and enjoy ad-free viewing!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.systemSecondaryBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer() // Push content to top
            }
        }
        .background(Color.black.ignoresSafeArea()) // Ensure black background
        .preferredColorScheme(.dark) // Force dark mode for consistency
        .navigationTitle("Rewards") // Assuming this view is inside a NavigationView
        .navigationBarTitleDisplayMode(.inline)
    }
}

// View for each day in the check-in row
struct DailyCheckinItemView: View {
    let day: DailyCheckinDay
    
    var body: some View {
        VStack(spacing: 4) {
            Text("+\(day.rewardAmount)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(day.status == .checkedIn ? .secondary : .primary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(day.status == .available ? Color.yellow.opacity(0.3) : Color.clear)
                .cornerRadius(4)
            
            Image(systemName: day.status == .checkedIn ? "checkmark.circle.fill" : "circle")
                .foregroundColor(day.status == .checkedIn ? .green : (day.status == .available ? .yellow : .gray))
                .font(.title3)
            
            Text("Day \(day.id)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity) // Distribute space evenly
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
                .frame(width: 25) // Align icons
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    Text(action.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action.buttonLabel, action: performAction)
                .buttonStyle(GradientButtonStyle(gradient: buttonGradient, disabled: action.isButtonDisabled))
                .font(.caption) // Smaller font for buttons in list
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