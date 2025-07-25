//
//  App.swift
//  App (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/app
//  https://docs.swiftylaun.ch/basics/how-to-work-with-swiftylaunch
//
//  Main entrance of your app.
//  Define your app-wide settings here, objects that are shared within the
//  app via EnvironmentObject, and attach app-wide view modifiers.
//

import AnalyticsKit
import Mixpanel
import CrashlyticsKit
import Sentry
import InAppPurchaseKit
import NotifKit
import OneSignalFramework
import SharedKit
import SupabaseKit
import SwiftUI
import UIKit
import VideoPlayerKit
import AVFoundation

@main
struct MainApp: App {

	// Allows us to tap into AppDelegate
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

	/// Object to access DBKit and AuthKit (SupabaseKit).
	@StateObject var db: DB

	/// Object to access InAppPurchaseKit
	@StateObject var iap = InAppPurchases()

	// To track when app goes into foreground/background
	// We use this to clear push notifications when the app is opened.
	@Environment(\.scenePhase) var scenePhase

	init() {
		// Configure DB singleton with auth state change handler
		DB.configure { event, session in
			if let user = session?.user {
				// Logged in => Privacy Consent Given during signup (NotifKit)
				PushNotifications.oneSignalConsentGiven()

				// Identify OneSignal with Supabase user (NotifKit & AuthKit)
				PushNotifications.associateUserWithID(user.id.uuidString)
				
				// Get Mixpanel Associated User Properties (AnalyticsKit & AuthKit)
				var userProperties = DB.convertAuthUserToAnalyticsUserProperties(user)
				
				let mixpanelProperties = userProperties.reduce(into: Properties()) { result, element in
					// Only add values that conform to MixpanelType
					if let value = element.value as? MixpanelType {
						result[element.key] = value
					}
				}

				// Identify RevenueCat SDK with Supabase user (InAppPurchaseKit & AuthKit)
				InAppPurchases.associateUserWithID(
					user.id.uuidString,
					currentUserProperties: userProperties
				) {
					userProperties = $0
				}
				Analytics.associateUserWithID(user.id.uuidString, userProperties: mixpanelProperties)
			} else {
				Analytics.removeUserIDAssociation()
				InAppPurchases.removeUserIDAssociation()
				PushNotifications.removeUserIDAssociation()
			}
		}
		
		// Initialize StateObject with shared instance
		_db = StateObject(wrappedValue: DB.shared)
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()

				// For different types of requests: Camera Request, Location Request, Request to Review the App, etc. See `askUserFor.swift` in SharedKit for more information.
				.modifier(ShowRequestSheetWhenNeededModifier())

				// Will show the WhatsNewView sheet if the user opens the app for the first time with a specific app version (for updates)
				.modifier(ShowFeatureSheetOnNewAppVersionModifier())

				// Will show the OnboardingView if the user opens the app for the first time
				.modifier(ShowOnboardingViewOnFirstLaunchEverModifier())

				// Will show a sheet that will ask the user to give permission for push notifications, when `PushNotifications.showNotificationsPermissionsSheet()` is called (NotifKit)
				.modifier(ShowPushNotificationPermissionSheetIfNeededModifier())

				// This modifier allows you to show the sign in sheet with the `showSignInSheet` function (SupabaseKit)
				.modifier(ShowSignInSheetWhenCalledModifier(db))

				// This modifier allows you to show the paywall sheet with the `InAppPurchases.showPaywallSheet` function (InAppPurchaseKit)
				.modifier(ShowPaywallSheetWhenCalledModifier(iap))

				// Clear all notifications when app is opened (NotifKit)
				.onAppearAndChange(of: scenePhase) {
					if scenePhase == .active {
						PushNotifications.clearAllAppNotifications()
					}
				}

				.environmentObject(db)
				.environmentObject(iap)
		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate, OSNotificationLifecycleListener, OSPushSubscriptionObserver,
	OSNotificationClickListener
{

	/// This function is called by the UIApplicationDelegate when App has finished loading and is launched.
	///
	/// Learn more about the app lifecycle [here](https://manasaprema04.medium.com/application-life-cycle-in-ios-f7365d8c1636).
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		// Initialize AnalyticsKit
		Analytics.initMixpanel()
        Crashlytics.shared.configure()
		InAppPurchases.initRevenueCat()
        MuxVideoPlayer.initMuxPlayer()
        
        // Configure Audio Session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            print("[AUDIO] Successfully configured audio session for video playback")
        } catch {
            print("[AUDIO] Failed to set up audio session: \(error)")
        }

		// If OneSignal initialized successfully, we set up the push notification observers and clear all notifications when the app is opened
		PushNotifications.initOneSignal(launchOptions)

		// To route push notifications to in-app messages, we need to listen to the notification lifecycle
		OneSignal.Notifications.addForegroundLifecycleListener(self)

		// Clear all notifications (if any)
		PushNotifications.clearAllAppNotifications()

		// Calls onPushSubscriptionDidChange whenever a user's push subscription changes
		// https://documentation.onesignal.com/docs/mobile-sdk#observe-push-subscription-changes
		OneSignal.User.pushSubscription.addObserver(self)

		// calls onClick whenever the user opens a notification
		OneSignal.Notifications.addClickListener(self)

		return true
	}

	/// Set SceneDelegate as the delegate for the main window
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	)
		-> UISceneConfiguration
	{
		let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
		if connectingSceneSession.role == .windowApplication {
			configuration.delegateClass = SceneDelegate.self
		}
		return configuration
	}

	/// Here you can peform operations depending on whether the user has accepted or declined push notifications
	func onPushSubscriptionDidChange(state: OSPushSubscriptionChangedState) {
		Analytics.capture(
			.info, id: "user_push_notif_permission_update",
			longDescription:
				"[NOTIF] User Changed Push Notification Preference to \(state.current.optedIn ? "'OPTED IN'" : "'OPTED OUT'").",
			source: .notif,
			relevancy: .high)
	}

	/// Here you can perform operations when the user opens a notification (e.g. open a specific View)
	func onClick(event: OSNotificationClickEvent) {
		Analytics.capture(
			.info, id: "user_opened_notification",
			longDescription:
				"[NOTIF] User Openened Notification with id '\(event.notification.notificationId ?? "UNKNOWN")'.",
			source: .notif)
	}

	/// Will be called when the app receives a notification AND is in the foreground
	/// https://docs.swiftylaun.ch/module/notifkit/routing-to-in-app-notifications
	func onWillDisplay(event: OSNotificationWillDisplayEvent) {
		event.preventDefault()

		// If we can't find these properties in additional data, just show notification as usual
		guard let notifTitle = event.notification.title,
			let notifMessage = event.notification.body,
			let additionalData = event.notification.additionalData,
			let symbol = additionalData["inAppSymbol"] as? String,
			let color = additionalData["inAppColor"] as? String
		else {
			event.notification.display()
			return
		}

		// optionally you can pass notifSize as a parameter
		var notifSize: InAppNotificationStyle.NotificationSize = .normal
		if let size = additionalData["inAppSize"] as? String {
			if size == "compact" {
				notifSize = .compact
			}
		}

		// optionally you can pass notifHaptics as a parameter
		var notifHaptics: UINotificationFeedbackGenerator.FeedbackType = .warning
		if let size = additionalData["inAppHaptics"] as? String {
			if size == "error" {
				notifHaptics = .error
			} else if size == "success" {
				notifHaptics = .success
			}
		}

		showInAppNotification(
			content: .init(
				title: LocalizedStringKey(notifTitle),
				message: LocalizedStringKey(notifMessage)),
			style: .init(
				sfSymbol: symbol,
				symbolColor: Color(hex: color),
				size: notifSize,
				hapticsOnAppear: notifHaptics))

	}
}

// https://swiftylaun.ch/blog/swiftui-overlay-over-every-view
// https://docs.swiftylaun.ch/module/sharedkit/in-app-notifications
final class SceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate {

	var keyWindow: UIWindow?
	var secondaryWindow: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		if let windowScene = scene as? UIWindowScene {
			setupSecondaryOverlayWindow(in: windowScene)
		}
		// Change the AccentColor in App/Resources/Assets to style the app
		UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.init(
			named: "AccentColor")
	}

	// Secondary, transparent window for overlays that go over all views.
	func setupSecondaryOverlayWindow(in scene: UIWindowScene) {
		let secondaryViewController = UIHostingController(
			rootView:
				EmptyView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)

				// This modifier allows you to show in-app notifications with the `showInAppNotification` function
				.modifier(ShowInAppNotificationsWhenCalledModifier())

		)
		secondaryViewController.view.backgroundColor = .clear

		let secondaryWindow = PassThroughWindow(windowScene: scene)
		secondaryWindow.rootViewController = secondaryViewController
		secondaryWindow.isHidden = false
		self.secondaryWindow = secondaryWindow
	}
}

class PassThroughWindow: UIWindow {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		// Get view from superclass.
		guard let hitView = super.hitTest(point, with: event) else { return nil }
		// If the returned view is the `UIHostingController`'s view, ignore.
		return rootViewController?.view == hitView ? nil : hitView
	}
}
