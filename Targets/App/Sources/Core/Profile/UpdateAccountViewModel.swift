import SwiftUI
import Combine
import SupabaseKit
import Supabase // Import Supabase directly for UserAttributes
import Foundation // For NSPredicate

@MainActor
class UpdateAccountViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAnonymous: Bool = true
    // Use AppStorage to track pending verification across sessions
    @AppStorage("pendingVerificationUserID") private var pendingVerificationUserID: String = ""

    private var db: DB

    init(db: DB) {
        self.db = db
        fetchUserDetails()
    }

    func fetchUserDetails() {
        guard let user = db.currentUser else {
            userEmail = ""
            isAnonymous = true
            return
        }

        self.isAnonymous = user.isAnonymous
        self.userEmail = user.email ?? ""
    }

    func updateAccount() async -> Bool {
        guard let user = db.currentUser else {
            errorMessage = "Error: No user session found."
            return false
        }

        let trimmedEmail = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        // Email is required
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email address cannot be empty."
            return false
        }

        // Basic email validation
        guard trimmedEmail.isValidEmail() else {
            errorMessage = "Please enter a valid email address."
            return false
        }

        isLoading = true
        errorMessage = nil

        let attributes = Supabase.UserAttributes(
            email: trimmedEmail,
            data: [:]
        )

        do {
            // Call the updateUser method in DB
            try await db.updateUser(attributes: attributes)

            isLoading = false
            return true
        } catch let error as AuthKitError {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}

// Helper for basic email validation (consider moving to SharedKit)
private extension String {
    func isValidEmail() -> Bool {
        // More robust regex allowing for newer TLDs
        let emailRegEx = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
} 