//
//  RewardsView.swift
//  App
//

import SwiftUI
import SharedKit
import InAppPurchaseKit

struct RewardsView: View {
    @State private var coins = 150
    @State private var streakDays = 3
    @State private var showDailyRewardClaimed = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Coin balance display
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(coins)")
                                .font(.system(size: 40, weight: .bold))
                            Text("COINS")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Daily streak
                    VStack(spacing: 15) {
                        Text("Watch Streak: \(streakDays) days")
                            .font(.headline)
                        
                        HStack(spacing: 10) {
                            ForEach(0..<7) { day in
                                VStack {
                                    Circle()
                                        .fill(day < streakDays ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                    Text("D\(day+1)")
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Button(action: {
                            // Award daily reward
                            withAnimation {
                                coins += 25
                                showDailyRewardClaimed = true
                            }
                            
                            // Reset after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showDailyRewardClaimed = false
                            }
                        }) {
                            Text("Claim Daily Reward")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .disabled(showDailyRewardClaimed)
                        .opacity(showDailyRewardClaimed ? 0.5 : 1)
                        
                        if showDailyRewardClaimed {
                            Text("Daily reward claimed: +25 coins!")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Earn more coins
                    VStack(alignment: .leading, spacing: 15) {
                        Text("EARN MORE COINS")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Show rewarded ad
                            coins += 10
                        }) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Watch an Ad")
                                        .font(.headline)
                                    Text("Earn 10 coins")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            // Prompt sign-in flow
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Sign In")
                                        .font(.headline)
                                    Text("Get 50 bonus coins")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Buy coin packs
                    VStack(alignment: .leading, spacing: 15) {
                        Text("BUY COINS")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(coinPacks) { pack in
                            CoinPackItem(pack: pack)
                        }
                    }
                    
                    // VIP Subscription
                    VStack(alignment: .leading, spacing: 15) {
                        Text("VIP SUBSCRIPTION")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Show subscription options
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Unlock All Episodes")
                                        .font(.headline)
                                    Text("Subscribe for unlimited access")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Rewards")
        }
    }
    
    // Sample data
    var coinPacks: [CoinPack] {
        [
            CoinPack(id: "1", amount: 100, price: "$1.99", bestValue: false),
            CoinPack(id: "2", amount: 300, price: "$4.99", bestValue: false),
            CoinPack(id: "3", amount: 700, price: "$9.99", bestValue: true)
        ]
    }
}

struct CoinPack: Identifiable {
    let id: String
    let amount: Int
    let price: String
    let bestValue: Bool
}

struct CoinPackItem: View {
    let pack: CoinPack
    
    var body: some View {
        Button(action: {
            // Purchase logic
        }) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading) {
                    Text("\(pack.amount) Coins")
                        .font(.headline)
                    Text(pack.price)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if pack.bestValue {
                    Text("BEST VALUE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(5)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(pack.bestValue ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .padding(.horizontal)
    }
}

#Preview {
    RewardsView()
} 