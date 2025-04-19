//
//  RewardedAd.swift
//  Reels
//
//  Created by Aize Igbinakenzua on 2025-04-18.
//

import GoogleMobileAds
import SharedKit
import SwiftUI

/// Make sure to follow Google AdMob guidelines and policies.
/// https://support.google.com/admob/answer/6329638

public class RewardedAdController: NSObject, GADFullScreenContentDelegate {
    private var rewardedAd: GADRewardedAd?
    private var isLoading = false
    private let adUnitID: String
    
    public var onAdLoaded: (() -> Void)?
    public var onAdDismissed: (() -> Void)?
    public var onAdFailedToLoad: ((Error) -> Void)?
    public var onReward: ((GADAdReward) -> Void)?
    
    public init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
        loadRewardedAd()
    }
    
    public func loadRewardedAd() {
        guard !isLoading else { return }
        isLoading = true
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            self?.isLoading = false
            
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                self?.onAdFailedToLoad?(error)
                return
            }
            
            print("Rewarded ad loaded successfully")
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            self?.onAdLoaded?()
        }
    }
    
    public func showAd(from viewController: UIViewController) {
        guard let rewardedAd = rewardedAd else {
            print("Ad not ready")
            loadRewardedAd()
            return
        }
        
        rewardedAd.present(fromRootViewController: viewController) { [weak self] in
            print("User earned reward: \(rewardedAd.adReward.amount) \(rewardedAd.adReward.type)")
            self?.onReward?(rewardedAd.adReward)
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad dismissed")
        onAdDismissed?()
        loadRewardedAd() // Load the next ad
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        loadRewardedAd() // Try to load another ad
    }
}

public struct RewardedAdView: View {
    @StateObject private var viewModel: RewardedAdViewModel
    let onReward: (GADAdReward) -> Void
    
    public init(adUnitID: String, onReward: @escaping (GADAdReward) -> Void) {
        _viewModel = StateObject(wrappedValue: RewardedAdViewModel(adUnitID: adUnitID))
        self.onReward = onReward
    }
    
    public var body: some View {
        Button(action: {
            viewModel.showAd(onReward: onReward)
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.blue)
                Text("Watch Ad for Reward")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
        .disabled(!viewModel.isAdReady)
        .opacity(viewModel.isAdReady ? 1.0 : 0.5)
    }
}

class RewardedAdViewModel: ObservableObject {
    private let adController: RewardedAdController
    @Published private(set) var isAdReady = false
    
    init(adUnitID: String) {
        self.adController = RewardedAdController(adUnitID: adUnitID)
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        adController.onAdLoaded = { [weak self] in
            DispatchQueue.main.async {
                self?.isAdReady = true
            }
        }
        
        adController.onAdDismissed = { [weak self] in
            DispatchQueue.main.async {
                self?.isAdReady = false
            }
        }
        
        adController.onAdFailedToLoad = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isAdReady = false
            }
        }
    }
    
    func showAd(onReward: @escaping (GADAdReward) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Failed to get root view controller")
            return
        }
        
        adController.onReward = onReward
        adController.showAd(from: rootViewController)
    }
}

#Preview {
    RewardedAdView(adUnitID: "ca-app-pub-3940256099942544/1712485313") { reward in
        print("Reward earned: \(reward.amount) \(reward.type)")
    }
}
