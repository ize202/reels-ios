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

    // Grid columns for My Collection - Changed to 2 columns
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
        // GridItem(.flexible(), spacing: 15) // Remove third column
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

                    // Recently Watched Grid (replaces horizontal scroll)
                    if !viewModel.recentlyWatched.isEmpty {
                        LibrarySectionHeader(title: "Recently Watched")
                            .padding(.top, -8)
                        // Use LazyVGrid instead of ScrollView + HStack
                        LazyVGrid(columns: columns, spacing: 20) { // Use updated columns
                            ForEach(viewModel.recentlyWatched) { series in
                                NavigationLink(destination: FeedView(db: db, seriesId: UUID(uuidString: series.seriesId) ?? UUID(), startingEpisode: series.lastWatchedEpisode)) {
                                    LibrarySeriesCard(series: series) // Use the new card
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Handle empty state (only checks recently watched now)
                    if viewModel.recentlyWatched.isEmpty && !viewModel.isLoading {
                        Text("You haven't watched anything recently.") // Updated empty state message
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

// Card for "Recently Watched" section - adapted from HomeView's SeriesCard
struct LibrarySeriesCard: View {
    let series: WatchedSeries
    let gradient = Gradient(colors: [Color.systemSecondaryBackground, Color.systemTertiaryBackground])

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Group the conditional content to apply modifiers commonly
            Group {
                if let coverImage = series.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                } else {
                    // Placeholder if image not loaded yet
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay(
                            Image(systemName: "play.rectangle.fill") // Icon for recently watched
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
            }
            .frame(height: 200) // Apply frame to the Group
            .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply clipShape to the Group
            
            // Series Title
            Text(series.title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 4)
            
            // Progress Text (e.g., "EP. 3")
            Text(series.progressString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LibraryView(db: DB())
}
