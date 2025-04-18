//
//  Ads.swift
//  Reels
//
//  Created by Aize Igbinakenzua on 2025-04-18.
//

import Foundation
import GoogleMobileAds

public class Ads {
    // Used once in App.swift to initialize GoogleMobileAds
    public static func initGoogleMobileAds() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // see https://docs.swiftylaun.ch/project-setup/adskit#setting-test-device-id
        // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "TEST_DEVICE_IDENTIFIER" ]
    }
}
