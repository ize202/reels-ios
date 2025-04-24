//
//  LibraryView.swift
//  App
//

import SwiftUI
import SharedKit
import SupabaseKit

struct LibraryView: View {
    // Use the ViewModel
    @StateObject private var viewModel: LibraryViewModel
    @EnvironmentObject var db: DB

    // Grid columns for My Collection
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    // Initialize viewModel in init
    init(db: DB) {
        _viewModel = StateObject(wrappedValue: LibraryViewModel(db: db))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Screen Title
                    Text("Library")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    // Continue Watching section
                    if !viewModel.recentlyWatched.isEmpty {
                        LibrarySectionHeader(title: "Recently Watched")
                            .padding(.top, -8)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.recentlyWatched) { series in
                                    NavigationLink(destination: FeedView(db: db, seriesId: UUID(uuidString: series.seriesId) ?? UUID(), startingEpisode: series.lastWatchedEpisode)) {
                                        RecentlyWatchedCard(series: series)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // My Collection section
                    if !viewModel.savedCollection.isEmpty {
                        LibrarySectionHeader(title: "Saved Series")
                            .padding(.top, -8)
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(viewModel.savedCollection) { series in
                                NavigationLink(destination: FeedView(db: db, seriesId: UUID(uuidString: series.seriesId) ?? UUID())) {
                                    MyCollectionCard(series: series)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Handle empty state
                    if viewModel.recentlyWatched.isEmpty && viewModel.savedCollection.isEmpty && !viewModel.isLoading {
                        Text("Your library is empty.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    }
                }
                .padding(.vertical, 10)
            }
            .background(Color.black) // Apply black background
            .preferredColorScheme(.dark) // Force dark mode
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
                // Optional: Add error message display if needed
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(hex: "9B79C1"))
    }
}

// --- Simplified Section Header --- 
struct LibrarySectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.bottom, 4)
    }
}

// --- Card Views for Library ---

// Card for "Recently Watched" section
struct RecentlyWatchedCard: View {
    let series: WatchedSeries
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Thumbnail - Replace placeholder with AsyncImage later if needed
            RoundedRectangle(cornerRadius: 8)
                .fill(series.coverUrl == nil ? Color.systemSecondaryBackground : Color.clear) // Show bg if no image
                .aspectRatio(2/3, contentMode: .fit) // Use portrait aspect ratio
                .overlay(
                    Group { // Use Group to conditionally show image or placeholder
                        if let url = series.coverUrl {
                             // TODO: Replace with AsyncImage(url: url) ... for actual image loading
                            Image(systemName: "photo") // Placeholder for now
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "play.rectangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Clip the overlay image
            
            Text(series.title)
                .font(.subheadline) // Slightly smaller than headline
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(series.progressString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 160) // Constrain card width
        .contentShape(Rectangle()) // Make the entire card tappable
        .buttonStyle(PlainButtonStyle()) // Remove default button styling from NavigationLink
    }
}

// Card for "My Collection" section (similar to HomeView SeriesCard)
struct MyCollectionCard: View {
    let series: SavedSeries
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Thumbnail - Replace placeholder with AsyncImage later
            RoundedRectangle(cornerRadius: 10)
                 .fill(series.coverUrl == nil ? Color.systemSecondaryBackground : Color.clear) // Show bg if no image
                .aspectRatio(2/3, contentMode: .fit) // Portrait aspect ratio
                .overlay(
                     Group { // Use Group to conditionally show image or placeholder
                        if let url = series.coverUrl {
                             // TODO: Replace with AsyncImage(url: url) ... for actual image loading
                            Image(systemName: "photo") // Placeholder for now
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip the overlay image
            
            Text(series.title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 2)
            
            Text(series.episodesString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle()) // Make the entire card tappable
        .buttonStyle(PlainButtonStyle()) // Remove default button styling from NavigationLink
    }
}
