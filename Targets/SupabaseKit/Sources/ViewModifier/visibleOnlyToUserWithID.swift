//
//  visibleOnlyToUserWithID.swift
//  SupabaseKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/authkit/lock-views-behind-auth#the-visibleonlytouserwithid-view-modifier
//

import AnalyticsKit
import SharedKit
import SwiftUI

// NOTE: - It is recommended to protect sensitive/private user screens on the server level

extension View {
	/// This modifier makes sure that the view that it is applied to will only be shown if the user whose ID matches the one passed to this modifier
	/// - Parameters:
	///   - userID: The ID of the user that is allowed to see this view.
	///   - db: Pass the state of the Database.
	///   - onCancel: A button will be shown in the top left corner, that will let the user close the Sign In. Use this to close the View that requires the user to be logged in.
	public func visibleOnlyToUserWithID(_ userID: UUID?, db: DB, onCancel: @escaping () -> Void) -> some View {
		modifier(RequireLoginWithID(db: db, userID: userID, onCancel: onCancel))
	}
}

private struct RequireLoginWithID: ViewModifier {

	@ObservedObject var db: DB

	let userID: UUID?
	let onCancel: () -> Void

	init(db: DB, userID: UUID?, onCancel: @escaping () -> Void) {
		self.db = db
		self.userID = userID
		self.onCancel = onCancel
	}

	func body(content: Content) -> some View {
		if userID != nil && db.authState == .signedIn && db.currentUser?.id == userID {
			content
		} else {
			HeroView(sfSymbolName: "person.circle", title: "No Access", subtitle: "Sorry, you can't access this.")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.overlay(alignment: .topLeading) {
					Button("Cancel", action: onCancel)
						.padding()
						.captureTaps("dismiss_view_btn", fromView: "RequireLoginWithID")
				}
		}
	}
}
