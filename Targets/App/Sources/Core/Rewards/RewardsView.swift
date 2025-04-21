//
//  RewardsView.swift
//  App
//

import SwiftUI
import SharedKit
import InAppPurchaseKit

struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    
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
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isCheckinAvailable ? Color(hex: "9B79C1") : Color.gray)
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
                
                // Earn Rewards Section - Now driven by ViewModel
                VStack(alignment: .leading, spacing: 0) {
                    Text("Earn Rewards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // Loop through actions from ViewModel
                    ForEach(viewModel.staticRewardActions) { action in
                        StaticRewardActionRow(action: action) { // Pass action ID to closure
                            viewModel.performStaticRewardAction(id: action.id)
                        }
                        // Add divider if it's not the last item
                        if action.id != viewModel.staticRewardActions.last?.id {
                            Divider().padding(.leading, 55) // Indent divider
                        }
                    }
                }
                .padding(.top) // Changed from .padding(.vertical) to only top padding
                
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
            return Color(hex: "503370")
        case .available:
            return .yellow
        case .upcoming:
            return .gray
        }
    }
}

// View for HARDCODED Earn Rewards list items - UPDATED
struct StaticRewardActionRow: View {
    let action: StaticRewardAction // Accept the model object
    let performAction: () -> Void // Keep simple closure for button tap

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: action.iconName)
                .font(.title3)
                .frame(width: 24)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(action.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(action.description) // Use computed description from model
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action.isClaimed ? "Claimed" : "Claim", action: {
                if !action.isClaimed {
                    performAction() // Call the closure passed from the parent
                }
            })
            .buttonStyle(FlatButtonStyle(disabled: action.isClaimed))
            .disabled(action.isClaimed) // Ensure button is disabled based on model state
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
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                disabled ? Color.gray : (configuration.isPressed ? Color(hex: "9B79C1").opacity(0.8) : Color(hex: "9B79C1"))
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
