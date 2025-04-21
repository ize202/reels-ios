//
//  ProfileView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit

struct ProfileView: View {
    @State private var isSignedIn = false
    @State private var showSignInSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack(spacing: 16) {
                        if isSignedIn {
                            // User profile image
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                            
                            // User info
                            Text("User Name")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("user@example.com")
                                .foregroundColor(.secondary)
                                
                            // Stats
                            HStack(spacing: 30) {
                                StatItem(value: "150", label: "Coins")
                                StatItem(value: "5", label: "Series")
                                StatItem(value: "32", label: "Episodes")
                            }
                            .padding(.top, 8)
                            
                            // Sign out button
                            Button("Sign Out") {
                                // Sign out logic
                                isSignedIn = false
                            }
                            .foregroundColor(.red)
                            .padding(.top, 8)
                            
                        } else {
                            // Not signed in
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.slash")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                            
                            Text("Not Signed In")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Sign in to sync your progress and coins across devices")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showSignInSheet = true
                            }) {
                                Text("Sign In")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Settings sections
                    SettingsSection(title: "Account", options: [
                        SettingsOption(icon: "creditcard", title: "Purchase History", color: .blue),
                        SettingsOption(icon: "bell", title: "Notifications", color: .red),
                        SettingsOption(icon: "icloud.and.arrow.down", title: "Restore Purchases", color: .purple)
                    ])
                    
                    SettingsSection(title: "Support", options: [
                        SettingsOption(icon: "questionmark.circle", title: "Help Center", color: .green),
                        SettingsOption(icon: "envelope", title: "Contact Us", color: .orange),
                        SettingsOption(icon: "star", title: "Rate the App", color: .yellow)
                    ])
                    
                    SettingsSection(title: "About", options: [
                        SettingsOption(icon: "doc.text", title: "Terms of Service", color: .gray),
                        SettingsOption(icon: "hand.raised", title: "Privacy Policy", color: .gray)
                    ])
                    
                    // App version
                    Text("App Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showSignInSheet) {
                SignInView {
                    // On successful sign in
                    isSignedIn = true
                    showSignInSheet = false
                }
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsSection: View {
    let title: String
    let options: [SettingsOption]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(options) { option in
                    SettingsOptionRow(option: option)
                    
                    if option.id != options.last?.id {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct SettingsOption: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
}

struct SettingsOptionRow: View {
    let option: SettingsOption
    
    var body: some View {
        Button(action: {
            // Handle option selection
        }) {
            HStack {
                Image(systemName: option.icon)
                    .font(.title3)
                    .foregroundColor(option.color)
                    .frame(width: 32, height: 32)
                
                Text(option.title)
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .foregroundColor(.primary)
    }
}

// Placeholder for SignInView
struct SignInView: View {
    var onSignInSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)
            
            // Sign in options
            Button(action: {
                // Handle Apple sign in
                onSignInSuccess()
            }) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Sign in with Apple")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Handle email sign in
                onSignInSuccess()
            }) {
                HStack {
                    Image(systemName: "envelope")
                    Text("Sign in with Email")
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button("Cancel") {
                // Dismiss sheet
            }
            .padding(.top)
        }
        .padding()
    }
}

#Preview {
    ProfileView()
} 