//
//  AdsKitExample.swift
//  Reels
//
//  Created by Aize Igbinakenzua on 2025-04-18.
//

import GoogleMobileAds
import SwiftUI

public struct AdsKitExample: View {
    @State private var coins: Int = 0
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Current Coins: \(coins)")
                .font(.title)
            
            RewardedAdView(
                adUnitID: "ca-app-pub-3940256099942544/1712485313"  // Test ad unit ID
            ) { reward in
                // Handle the reward
                coins += Int(truncating: reward.amount)
            }
        }
        .padding()
    }
}

#Preview {
    AdsKitExample()
}
