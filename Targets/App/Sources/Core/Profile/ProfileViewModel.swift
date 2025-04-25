import SwiftUI
import Combine
import SupabaseKit
import InAppPurchaseKit
import SharedKit
import NotifKit

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var showUpdateSheet = false
    @Published var navigateToSettings = false
    @AppStorage("pendingVerificationUserID_v1") private var pendingVerificationUserID: String = ""
    
    var db: DB
    var iap: InAppPurchases
    private var cancellables = Set<AnyCancellable>()
    
    init(db: DB, iap: InAppPurchases) {
        self.db = db
        self.iap = iap
        
        // Set up observers for user state changes
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe user changes to clear pending state when appropriate
        // and trigger UI updates.
        db.objectWillChange
            .receive(on: DispatchQueue.main) // Ensure updates happen on the main thread
            .sink { [weak self] _ in
                self?.handleUserStateChange()
                // Ensure the view always re-evaluates when DB changes
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
        // Also observe IAP changes if needed for UI updates within the ViewModel
        iap.objectWillChange
             .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Trigger an objectWillChange for the ProfileView if IAP state affects its UI directly
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func handleUserStateChange() {
        guard let user = db.currentUser else {
            // User logged out, clear pending state if it exists
            if !pendingVerificationUserID.isEmpty {
                print("[ProfileViewModel] User logged out, clearing pending state.")
                pendingVerificationUserID = ""
            }
            return
        }

        // If the current user is no longer anonymous, but their ID matches
        // the one we stored for pending verification, clear the pending state.
        if !user.isAnonymous && user.id.uuidString == pendingVerificationUserID {
            print("[ProfileViewModel] User \(user.id.uuidString) verified, clearing pending state.")
            pendingVerificationUserID = ""
        }
    }
    
    // MARK: - User State Helpers
    
    /// True if the current user is anonymous AND their ID matches the one stored for pending verification.
    var isUserPendingVerification: Bool {
        guard let user = db.currentUser else { return false }
        // User must be anonymous AND their ID must match the stored pending ID.
        return user.isAnonymous && user.id.uuidString == pendingVerificationUserID
    }
    
    /// True if the current user is anonymous BUT their ID does NOT match the stored pending ID.
    /// This indicates a regular guest who hasn't attempted to link an email yet.
    var isAnonymousGuest: Bool {
        guard let user = db.currentUser else { return false }
        // User is anonymous, and we are NOT waiting for them to verify an email.
        return user.isAnonymous && user.id.uuidString != pendingVerificationUserID
    }
    
    /// True if the current user is NOT anonymous (i.e., they have linked an email or used another provider).
    var isPermanentUser: Bool {
        guard let user = db.currentUser else { return false }
        return !user.isAnonymous
    }
    
    var isSignedOut: Bool {
        db.currentUser == nil
    }
    
    // MARK: - Actions
    
    func refreshSession() async {
        await db.refreshSession()
        // No need for explicit objectWillChange.send() here,
        // the sink on db.objectWillChange should handle it.
    }
    
    func showSignIn() {
        db.showSignInSheet()
    }
    
    func showPaywall() {
        InAppPurchases.showPaywallSheet()
    }
    
    func requestAppRating() async {
        await askUserFor(.appRating)
    }
    
    func openNotificationSettings() async {
        // If we already have permission, open system settings
        // Otherwise show the permission request sheet
        if await PushNotifications.hasNotificationsPermission() {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
        } else {
            PushNotifications.showNotificationsPermissionsSheet()
        }
    }
} 