//
//  ProfileView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit
import InAppPurchaseKit
import NotifKit

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var iap: InAppPurchases
    @EnvironmentObject var db: DB
    @StateObject private var viewModel: ProfileViewModel
    
    init() {
        // Initialize ViewModel with @StateObject
        // Note: We can't access EnvironmentObject during init, so we pass them in onAppear
        _viewModel = StateObject(wrappedValue: ProfileViewModel(db: DB(), iap: InAppPurchases()))
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                scrollableContent
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $viewModel.showUpdateSheet) {
                UpdateAccountView(db: db)
                    .environmentObject(db)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    print("[ProfileView] App became active, attempting to refresh session.")
                    Task {
                        await viewModel.refreshSession()
                    }
                }
            }
            .onAppear {
                // Update ViewModel with current environment objects
                viewModel.db = db
                viewModel.iap = iap
            }
        }
        .modifier(ShowPushNotificationPermissionSheetIfNeededModifier())
    }
    
    // MARK: - Computed View Properties
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header Section
                Group {
                    if viewModel.isSignedOut {
                        signedOutView
                    } else if viewModel.isUserPendingVerification {
                        pendingVerificationView
                    } else if viewModel.isAnonymousGuest {
                        guestProfileHeader
                    } else if viewModel.isPermanentUser {
                        permanentUserProfileHeader
                    }
                }
                
                // VIP Banner (if not subscribed)
                if iap.subscriptionState == .notSubscribed {
                    vipBanner
                }
                
                // Settings List
                settingsList
                
                // Footer
                VStack(spacing: 4) {
                    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                       let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                        Text("Version \(version) (\(build))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("© \(String(Calendar.current.component(.year, from: Date()))) Slips LLC")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)
                .padding(.bottom, 16)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Profile Header Views
    
    private var pendingVerificationView: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.badge.clock")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "9B79C1"))
            
            Text("Check Your Email")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("We've sent a verification link to the email address you provided. Restart app to update profile.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task { await viewModel.refreshSession() }
            } label: {
                Label("Refresh Status", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .tint(Color(hex: "9B79C1"))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var guestProfileHeader: some View {
        Button(action: { viewModel.showUpdateSheet = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Guest")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Set Email to Secure Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "9B79C1"))
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private var permanentUserProfileHeader: some View {
        Button(action: { viewModel.navigateToSettings = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let user = db.currentUser {
                        let fullName = user.userMetadata["full_name"] as? String
                        let email = user.email
                        
                        // Primary display text
                        let primaryText = fullName ?? email ?? "Account"
                        Text(primaryText)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        // Secondary display text (email, only if different from primary and primary wasn't already email)
                        if let displayedName = fullName, // Check if full name was displayed
                           let validEmail = email, !validEmail.isEmpty, // Check if email exists
                           displayedName != validEmail { // Check if email is different from full name
                            Text(validEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Edit Profile Information")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    Task { await viewModel.refreshSession() }
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "9B79C1"))
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .background(
            NavigationLink(destination: SupabaseAccountSettingsView(popBackToRoot: {}),
                         isActive: $viewModel.navigateToSettings) { EmptyView() }
        )
    }
    
    private var signedOutView: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Signed Out")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Sign in to manage your account and sync your library.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Sign In / Sign Up") {
                viewModel.showSignIn()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "9B79C1"))
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Other Views
    
    private var vipBanner: some View {
        Button(action: { viewModel.showPaywall() }) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock VIP Access")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Watch all premium content without limits")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Text("Subscribe")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(Color(hex: "9B79C1"))
                    .cornerRadius(16)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "9B79C1"),
                        Color(hex: "503370")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private var settingsList: some View {
        VStack(spacing: 0) {
            Group {
                if iap.subscriptionState == .subscribed {
                    NavigationLink(destination: PremiumSettingsView(popBackToRoot: {})) {
                        SettingsRow(icon: "crown", title: "Membership")
                    }
                    Divider()
                }
                
                Button(action: { 
                    Task {
                        await viewModel.requestAppRating()
                    }
                }) {
                    SettingsRow(icon: "star", title: "Rate Us")
                }
                Divider()
                
                Button(action: { viewModel.openNotificationSettings() }) {
                    SettingsRow(icon: "bell", title: "Notifications")
                }
                Divider()
                
                NavigationLink(destination: Text("Contact Us")) {
                    SettingsRow(icon: "envelope", title: "Contact Us")
                }
                Divider()
                
                if let privacyURL = URL(string: "https://www.slips.app/privacy-policy") {
                    Link(destination: privacyURL) {
                        SettingsRow(icon: "shield.lefthalf.filled", title: "Privacy Policy")
                    }
                    Divider()
                }
                
                if let tosURL = URL(string: "https://www.slips.app/terms-of-service") {
                    Link(destination: tosURL) {
                        SettingsRow(icon: "doc.text", title: "Terms of Service")
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views
struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 24, height: 24)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Preview Provider
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let iapManager = InAppPurchases()
        let dbManager = DB()
        
        ProfileView()
            .environmentObject(iapManager)
            .environmentObject(dbManager)
            .preferredColorScheme(.dark)
    }
} 
