import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showSignInSheet: Bool = false

    // MARK: - Methods
    func handleSignInTap() {
        // Dispatch to the main queue asynchronously to avoid modifying state during view update
        DispatchQueue.main.async {
            self.showSignInSheet = true
        }
    }
    
    // Called when the sign-in sheet is dismissed without success or completed
    func handleSignInCancel() {
        // Also dispatch dismissal to avoid potential issues
        DispatchQueue.main.async {
            self.showSignInSheet = false
        }
    }

    // Removed: handleSignOut, handleSignInSuccess, handleDeleteAccount, handleRefillTap, fetchUserData
    // Functionality moved to DB object or SupabaseAccountSettingsView
} 