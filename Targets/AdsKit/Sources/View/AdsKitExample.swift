//
//  AdsKitExample.swift
//  Reels
//
//  Created by Aize Igbinakenzua on 2025-04-18.
//

import GoogleMobileAds
import SwiftUI

public struct AdsKitExamples: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack {

                // replace this test ad unit id with your actual ad unit id
                RewardedAd(adUnitID: "ca-app-pub-3940256099942544/3986624511")

                Spacer()
            }
            .navigationTitle("AdsKit Showroom")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AdsKitExamples()
}
