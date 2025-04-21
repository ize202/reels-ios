//
//  ProfileView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Image(systemName: viewModel.isSignedIn ? "person.fill" : "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userName ?? "Guest")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            if let uid = viewModel.userUID {
                                Text(uid)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            if viewModel.isSignedIn, let email = viewModel.userEmail {
                                Text(email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        if viewModel.isSignedIn {
                            Button("Sign Out") {
                                viewModel.handleSignOut()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                        } else {
                            Button {
                                viewModel.handleSignInTap()
                            } label: {
                                HStack {
                                    Text("Sign in")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    Button(action: {
                        print("VIP Banner Tapped")
                    }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Become VIP to enjoy all series for FREE")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Spacer()
                            Text("GO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow)
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        HStack {
                            Text("My Wallet")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                        Divider().background(Color.gray.opacity(0.5))

                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                                Text("\(viewModel.coinBalance)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button(action: viewModel.handleRefillTap) {
                                Text(viewModel.isSignedIn ? "Top Up" : "Refill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.isSignedIn ? .black : .white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(viewModel.isSignedIn ? Color.yellow : Color.pink)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        NavigationLink(destination: Text("Membership View")) {
                            SettingsOptionRow(option: SettingsOption(icon: "crown.fill", title: "Membership", color: .yellow))
                        }
                        Divider().padding(.leading, 56).background(Color.gray.opacity(0.5))

                        NavigationLink(destination: Text("Library View")) {
                            SettingsOptionRow(option: SettingsOption(icon: "list.bullet.below.rectangle", title: "My List", color: .blue))
                        }
                        Divider().padding(.leading, 56).background(Color.gray.opacity(0.5))
                        
                        Button(action: { print("Rate Us Tapped")}) {
                            SettingsOptionRow(option: SettingsOption(icon: "star.fill", title: "Rate Us", color: .orange))
                        }
                        Divider().padding(.leading, 56).background(Color.gray.opacity(0.5))

                        NavigationLink(destination: Text("Contact Us View")) {
                            SettingsOptionRow(option: SettingsOption(icon: "envelope.fill", title: "Contact Us", color: .green))
                        }
                        Divider().padding(.leading, 56).background(Color.gray.opacity(0.5))

                        NavigationLink(destination: Text("Settings View")) {
                            SettingsOptionRow(option: SettingsOption(icon: "gearshape.fill", title: "Settings", color: .gray))
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Text("App Version 1.0.0 (Build 1)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background(Color.black.ignoresSafeArea())
            .sheet(isPresented: $viewModel.showSignInSheet) {
                SignInView(
                    onSignInSuccess: { uid, email, name in
                        viewModel.handleSignInSuccess(uid: uid, email: email, name: name)
                    },
                    onCancel: viewModel.handleSignInCancel
                )
            }
            .onAppear {
                viewModel.fetchUserData()
            }
        }
        .accentColor(.white)
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
        HStack {
            Image(systemName: option.icon)
                .font(.headline)
                .foregroundColor(option.color)
                .frame(width: 28, height: 28)
                .padding(6)
                .background(option.color.opacity(0.15))
                .cornerRadius(8)
            
            Text(option.title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct SignInView: View {
    var onSignInSuccess: (_ uid: String, _ email: String?, _ name: String?) -> Void
    var onCancel: () -> Void
    
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Button {
                    print("Apple Sign In Tapped")
                    onSignInSuccess("simulated_apple_uid", "apple@example.com", "Apple User")
                } label: {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button {
                    print("Email Sign In Tapped")
                    onSignInSuccess("simulated_email_uid", email, "Email User")
                } label: {
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
                .disabled(email.isEmpty || password.isEmpty)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar, .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .accentColor(.white)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
} 
