//
//  ProfileView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header - Simplified
                    HStack(spacing: 16) {
                        // Profile Image - Using system background
                        Image(systemName: viewModel.isSignedIn ? "person.fill" : "person.crop.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                            .frame(width: 60, height: 60)
                            .background(Color(UIColor.tertiarySystemFill))
                            .clipShape(Circle())

                        // User Info - Cleaner typography
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userName ?? "Guest")
                                .font(.headline)
                            
                            if let uid = viewModel.userUID {
                                Text(uid)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // Sign In/Out - More subtle styling
                        if viewModel.isSignedIn {
                            Button("Sign Out") {
                                viewModel.handleSignOut()
                            }
                            .font(.subheadline)
                            .foregroundColor(.red)
                        } else {
                            Button {
                                viewModel.handleSignInTap()
                            } label: {
                                Text("Sign in")
                                    .font(.subheadline)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // VIP Banner - More subtle design
                    Button(action: {
                        print("VIP Banner Tapped")
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.primary)
                            Text("Become VIP to enjoy all series unlocked")
                                .font(.subheadline)
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

                    // Wallet Card - Simplified
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
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "503370"))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Settings List - Using system grouping
                    VStack(spacing: 0) {
                        Group {
                            NavigationLink(destination: Text("Membership")) {
                                SettingsRow(icon: "crown", title: "Membership")
                            }
                            Divider()
                            NavigationLink(destination: Text("Library")) {
                                SettingsRow(icon: "rectangle.stack", title: "Library")
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
                            NavigationLink(destination: Text("Settings")) {
                                SettingsRow(icon: "gearshape", title: "Settings")
                            }
                        }
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // App version and copyright
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
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $viewModel.showSignInSheet) {
                SignInView(
                    onSignInSuccess: { uid, email, name in
                        viewModel.handleSignInSuccess(uid: uid, email: email, name: name)
                    },
                    onCancel: viewModel.handleSignInCancel
                )
            }
        }
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

// MARK: - SignInView
struct SignInView: View {
    var onSignInSuccess: (_ uid: String, _ email: String?, _ name: String?) -> Void
    var onCancel: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Sign in options
                Button {
                    print("Apple Sign In Tapped")
                    onSignInSuccess("simulated_apple_uid", "apple@example.com", "Apple User")
                } label: {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Continue with Apple")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        onSignInSuccess("simulated_email_uid", email, "Email User")
                    } label: {
                        Text("Continue with Email")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
            .padding()
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
} 
