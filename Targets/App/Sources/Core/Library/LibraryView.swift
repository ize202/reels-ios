//
//  LibraryView.swift
//  App
//

import SwiftUI
import SharedKit

struct LibraryView: View {
    // Use the ViewModel
    @StateObject private var viewModel = LibraryViewModel()

    // Grid columns for My Collection
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        // Removed NavigationView
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
                                RecentlyWatchedCard(series: series)
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
                            MyCollectionCard(series: series)
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
        }
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
            // Placeholder Thumbnail - Apply same aspect ratio as MyCollectionCard
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.systemSecondaryBackground) 
                .aspectRatio(2/3, contentMode: .fit) // Use portrait aspect ratio
                // Let the ScrollView's context determine width, but set a height constraint for the row
                .overlay(
                    Image(systemName: "play.rectangle.fill") // Keep play icon maybe?
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
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
        // Remove fixed width for the VStack, let content define it within limits
        // .frame(width: 160)
    }
}

// Card for "My Collection" section (similar to HomeView SeriesCard)
struct MyCollectionCard: View {
    let series: SavedSeries
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Placeholder Thumbnail
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.systemSecondaryBackground) // Use shared color
                .aspectRatio(2/3, contentMode: .fit) // Portrait aspect ratio
                .overlay(
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
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
    }
}

#Preview {
    LibraryView()
} 
