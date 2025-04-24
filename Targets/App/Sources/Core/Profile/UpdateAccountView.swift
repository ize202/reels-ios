import SwiftUI
import SupabaseKit // Needed for DB environment object
import SharedKit // Potentially for LoadingOverlay or other UI elements

struct UpdateAccountView: View {
    @EnvironmentObject private var db: DB // Get the DB instance from environment
    @StateObject private var viewModel: UpdateAccountViewModel
    @Environment(\.dismiss) private var dismiss

    // Initializer to create the ViewModel using the injected DB
    init(db: DB) {
        _viewModel = StateObject(wrappedValue: UpdateAccountViewModel(db: db))
    }

    var body: some View {
        NavigationView { // Wrap in NavigationView for title and toolbar
            Form {
                Section(header: Text("Account Details"), footer: Text(viewModel.isAnonymous ? "Providing an email address will secure your account and allow you to sign in on other devices." : "Update your email address.")) {
                    // Removed: TextField for Display Name
                    
                    TextField("Email Address", text: $viewModel.userEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Display error messages if any
                if let errorMessage = viewModel.errorMessage {
                     Section {
                          Text(errorMessage)
                              .foregroundColor(.red)
                              .font(.caption)
                     }
                }
            }
            .navigationTitle(viewModel.isAnonymous ? "Secure Account" : "Update Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            if await viewModel.updateAccount() {
                                dismiss() // Dismiss the sheet on success
                            }
                        }
                    }
                    // Disable button while loading or if email is invalid/empty
                    .disabled(viewModel.isLoading || viewModel.userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .overlay {
                // Show loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
            }
            .onAppear {
                 // Re-fetch details in case they changed elsewhere or user re-opens sheet
                 viewModel.fetchUserDetails()
            }
            // Clear error message automatically after a delay
            .onChange(of: viewModel.errorMessage) { _, newValue in
                 if newValue != nil {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                           if viewModel.errorMessage == newValue { // Only clear if it hasn't changed again
                                withAnimation {
                                     viewModel.errorMessage = nil
                                }
                           }
                      }
                 }
            }
        }
    }
}

// --- Preview --- Requires DB to be properly set up or mocked
struct UpdateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let mockDB = DB() // Use your actual DB initializer
        // Mock different states for preview
        // Task { try? await mockDB._db.auth.signInAnonymously() } // Preview Anonymous
        // Task { try? await mockDB._db.auth.signInWithPassword(...) } // Preview Signed In

        // Need to wrap in something that provides the environment object
        UpdateAccountView(db: mockDB)
            .environmentObject(mockDB)
    }
}

// --- Make sure LoadingOverlay is defined, e.g., in SharedKit ---
// struct LoadingOverlay: View { ... } // As defined previously 