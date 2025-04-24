import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showSignInSheet: Bool = false

    // MARK: - Methods
    func handleSignInTap() {
        showSignInSheet = true
    }
    
    // Called when the sign-in sheet is dismissed without success or completed
    func handleSignInCancel() {
        showSignInSheet = false
    }

    // Removed: handleSignOut, handleSignInSuccess, handleDeleteAccount, handleRefillTap, fetchUserData
    // Functionality moved to DB object or SupabaseAccountSettingsView
} 