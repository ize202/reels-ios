//
//  ProfileView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit
import InAppPurchaseKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var iap: InAppPurchases
    @EnvironmentObject var db: DB

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Use computed property for scrollable content
                    scrollableContent
                    
                    // Footer is outside ScrollView - fixed at bottom
                    Spacer(minLength: 0) // Push footer to the bottom
                    
                    // Use computed property for footer content
                    footerContent(geometry: geometry)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $viewModel.showSignInSheet) {
                // Use SupabaseKit's SignInView
                SupabaseKit.SignInView(
                    db: db, 
                    onSignedIn: { 
                         print("Sign in successful from SupabaseKit.SignInView")
                         viewModel.handleSignInCancel() // Close sheet on success
                    }
                )
            }
        }
    }
    
    // MARK: - Computed View Properties
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // === Conditional Profile Header ===
                if db.currentUser == nil { // Not signed in
                    Button(action: { 
                        viewModel.handleSignInTap()
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                                .frame(width: 60, height: 60)
                                .background(Color(UIColor.tertiarySystemFill))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sign In / Sign Up")
                                    .font(.headline)
                                Text("Unlock full features & sync progress")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    
                } else { // Signed In
                    NavigationLink(destination: SupabaseAccountSettingsView(popBackToRoot: {})) { 
                        HStack(spacing: 16) {
                            // You might want a real profile image here later
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                                .frame(width: 60, height: 60)
                                .background(Color(UIColor.tertiarySystemFill))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(db.currentUser?.email ?? "Account")
                                    .font(.headline)
                                Text("Manage account & settings")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
                
                // === Conditional VIP Banner ===
                if iap.subscriptionState == .notSubscribed {
                    Button(action: { 
                        InAppPurchases.showPaywallSheet()
                    }) {
                        HStack(spacing: 12) {
                            // Enhanced icon with glow effect
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
                            
                            // Prominent call-to-action button
                            Text("Subscribe")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .foregroundColor(Color(hex: "9B79C1")) // Using primary brand color
                                .cornerRadius(16)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "9B79C1"),  // Primary purple
                                    Color(hex: "503370")   // Secondary purple
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

                /* === Wallet Section Commented Out ===
                VStack(spacing: 0) {
                    HStack {
                        Text("My Wallet")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                        .background(Color(UIColor.separator))

                    HStack {
                        // Coin balance
                        Label(
                            title: { Text("\(viewModel.coinBalance)").font(.title3).bold() },
                            icon: { Image(systemName: "circle.fill").foregroundColor(.yellow) }
                        )
                        
                        Spacer()
                        
                        // Top Up button
                        Button(action: viewModel.handleRefillTap) {
                            Text(viewModel.isSignedIn ? "Top Up" : "Get Coins")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "9B79C1"))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                */

                // === Settings List ===
                VStack(spacing: 0) {
                    Group {
                        // === Conditional Membership Row ===
                        if iap.subscriptionState == .subscribed {
                            NavigationLink(destination: PremiumSettingsView(popBackToRoot: { /* Need pop logic if deep */ })) {
                                SettingsRow(icon: "crown", title: "Membership")
                            }
                            Divider()
                        }
                        
                        Divider()
                        Button(action: { print("Rate Us Tapped") }) {
                            SettingsRow(icon: "star", title: "Rate Us")
                        }
                        Divider()
                        NavigationLink(destination: Text("Contact Us")) {
                            SettingsRow(icon: "envelope", title: "Contact Us")
                        }
                        Divider()
                        
                        // === Link Rows ===
                        // Use your actual URLs here
                        if let privacyURL = URL(string: "https://www.yourapp.com/privacy") {
                             Link(destination: privacyURL) {
                                 SettingsRow(icon: "shield.lefthalf.filled", title: "Privacy Policy")
                             }
                             Divider()
                        }
                        if let tosURL = URL(string: "https://www.yourapp.com/terms") {
                             Link(destination: tosURL) {
                                 SettingsRow(icon: "doc.text", title: "Terms of Service")
                             }
                             Divider()
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
            .padding(.bottom, 50) // Add extra bottom padding to ensure content is above footer
        }
    }
    
    private func footerContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 4) {
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                Text("Version \(version)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Text("© 2025 Slips LLC")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(width: geometry.size.width)
        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 16)
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

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Need to inject InAppPurchases & DB for preview
        let iapManager = InAppPurchases()
        let dbManager = DB()
        // Example: Preview non-subscribed state
        // iapManager.subscriptionState = .notSubscribed 
        // Example: Preview subscribed state
        // iapManager.subscriptionState = .subscribed 
        
        // Example: Preview signed-out state (default)
        // Example: Preview signed-in state (requires mocking user)
        // Task { try? await dbManager._db.auth.signInAnonymously() } 
        
        ProfileView()
            .environmentObject(iapManager)
            .environmentObject(dbManager) // Inject DB
            .preferredColorScheme(.dark)
    }
} 
