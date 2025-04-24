import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isSignedIn: Bool = false // Placeholder - Fetch actual state later
    @Published var showSignInSheet: Bool = false
    @Published var userName: String? = "Guest" // Placeholder matches anonymous design
    @Published var userEmail: String? = nil // Anonymous users likely don't have email shown
    @Published var coinBalance: Int = 10 // Placeholder, reflecting the anonymous design
    @Published var userUID: String? = "UID: 391954275" // Placeholder matches anonymous design

    // MARK: - Methods
    func handleSignInTap() {
        // Later, this might involve more logic before showing the sheet
        showSignInSheet = true
    }

    func handleSignOut() {
        // TODO: Add actual sign-out logic here (e.g., call Supabase auth)
        print("Signing out...")
        isSignedIn = false
        userName = "Guest"
        userEmail = nil
        coinBalance = 10 // Reset to default anonymous state
        userUID = "UID: 391954275" // Reset to default anonymous state
    }

    // This would be called *after* the SignInView completes successfully
    func handleSignInSuccess(uid: String, email: String?, name: String?) {
        print("Sign in successful for UID: \(uid)")
        // TODO: Add logic to fetch user data based on UID/email and update properties
        isSignedIn = true
        showSignInSheet = false // Close the sheet
        userName = name ?? "User" // Use provided name or default
        userEmail = email
        coinBalance = 150 // Fetch actual data post-login
        userUID = "UID: \(uid.prefix(9))..." // Show partial UID or fetch specific display ID
        
        // TODO: Potentially award first login bonus here if applicable
    }
    
    // Called when the sign-in sheet is dismissed without success
    func handleSignInCancel() {
        showSignInSheet = false
    }

    func handleRefillTap() {
        // TODO: Navigate to IAP/Refill view or show relevant sheet
        print("Refill/Top Up Tapped")
    }
    
    func handleDeleteAccount() {
        // TODO: Implement account deletion logic
        // This should probably show a confirmation alert first.
        // If confirmed, call Supabase auth to delete the user.
        // Handle potential errors and update the UI (e.g., sign out).
        print("Delete Account Tapped - Placeholder")
        // Example: Show an alert (implementation needed)
        // showDeleteConfirmationAlert = true 
    }
    
    func fetchUserData() {
        // TODO: Implement logic to fetch user data from Supabase/backend
        // This should update isSignedIn, userName, userEmail, coinBalance, userUID
        print("Fetching user data...")
        // Simulating data fetch for signed-in user for now
        // In reality, check Supabase auth state here
        // If Supabase says signed in:
        // self.handleSignInSuccess(uid: "fetched_uid", email: "fetched@email.com", name: "Fetched Name")
        // Else (anonymous or signed out):
        // self.handleSignOut() // Or ensure state matches anonymous
    }
} 