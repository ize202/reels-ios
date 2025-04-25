//
//  HomeView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    // Grid layout for series
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Initialize with the DB instance passed from parent
    init(db: DB) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(db: db))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App Title
                    Text("Reels")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.top)

                    // All Series Grid
                    if !viewModel.allSeries.isEmpty {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.allSeries) { series in
                                NavigationLink(destination: FeedView(db: viewModel.db, seriesId: series.id)) {
                                    SeriesCard(series: series)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(Color.black)
            .preferredColorScheme(.dark)
            .refreshable {
                do {
                    try await Task.sleep(nanoseconds: 500_000_000) // Add small delay for better UX
                    await viewModel.fetchData()
                } catch {
                    print("Refresh task cancelled")
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchData()
                            }
                        }
                        .foregroundColor(Color(hex: "9B79C1"))
                        .padding(.top, 8)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(hex: "9B79C1"))
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.horizontal)
    }
}

struct SeriesCard: View {
    let series: Series
    let gradient = Gradient(colors: [Color.systemSecondaryBackground, Color.systemTertiaryBackground])

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let coverUrl = series.coverUrl {
                AsyncImage(url: URL(string: coverUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
                        .overlay(
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }

            Text(series.title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 4)

            Text(series.genre)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.clear, lineWidth: 0)
        )
    }
}

// Kept for reference but no longer used
struct FeaturedSeriesCard: View {
    let series: Series
    let gradient = Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.8)])
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let coverUrl = series.coverUrl {
                AsyncImage(url: URL(string: coverUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.systemSecondaryBackground)
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                        )
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.systemSecondaryBackground)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    )
            }
            
            // Gradient overlay for text visibility
            LinearGradient(gradient: gradient, startPoint: .center, endPoint: .bottom)
                .cornerRadius(12)

            // Text content
            VStack(alignment: .leading) {
                Text(series.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                if let description = series.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 1)
                        .lineLimit(2)
                }
            }
            .padding()
        }
        .frame(height: 250)
        .cornerRadius(12)
    }
}


