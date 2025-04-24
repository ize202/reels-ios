import SwiftUI
import Combine
import SupabaseKit
import InAppPurchaseKit

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
        db.objectWillChange
            .sink { [weak self] _ in
                self?.handleUserStateChange()
            }
            .store(in: &cancellables)
            
        // Also observe IAP changes if needed for UI updates within the ViewModel
        iap.objectWillChange
            .sink { [weak self] _ in
                // Trigger an objectWillChange for the ProfileView if IAP state affects its UI directly
                // For now, ProfileView reads iap directly, so this might not be strictly necessary
                // unless ViewModel logic depends on iap.subscriptionState
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func handleUserStateChange() {
        if let user = db.currentUser {
            // Clear pending state if user is no longer anonymous
            if !user.isAnonymous && user.id.uuidString == pendingVerificationUserID {
                print("[ProfileViewModel] User verified, clearing pending state")
                pendingVerificationUserID = ""
            }
        } else {
            // User logged out, clear pending state
            if !pendingVerificationUserID.isEmpty {
                print("[ProfileViewModel] User logged out, clearing pending state")
                pendingVerificationUserID = ""
            }
        }
        // Manually trigger update since db changes don't automatically update ProfileViewModel
        objectWillChange.send()
    }
    
    // MARK: - User State Helpers
    
    var isUserPendingVerification: Bool {
        guard let user = db.currentUser else { return false }
        return user.isAnonymous && user.id.uuidString == pendingVerificationUserID
    }
    
    var isAnonymousGuest: Bool {
        guard let user = db.currentUser else { return false }
        return user.isAnonymous && user.id.uuidString != pendingVerificationUserID
    }
    
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
    }
    
    func showSignIn() {
        db.showSignInSheet()
    }
    
    func showPaywall() {
        InAppPurchases.showPaywallSheet()
    }
} 