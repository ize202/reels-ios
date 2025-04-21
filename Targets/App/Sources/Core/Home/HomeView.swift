//
//  HomeView.swift
//  App
//

import SwiftUI
import SharedKit

struct HomeView: View {
    // Instantiate the ViewModel
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // App Title
                Text("Reels")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top) // Add padding if needed

                // Featured Carousel Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Use data from ViewModel
                        ForEach(viewModel.featuredSeries) { series in 
                            FeaturedSeriesCard(series: series)
                                .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                        }
                    }
                    // Use scrollTargetLayout and scrollTargetBehavior for paging
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.horizontal) // Add padding to the sides of the scrollview content
                .padding(.bottom, 10) // Consistent bottom padding

                // New Releases section
                SectionHeader(title: "New Releases")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Use data from ViewModel
                        ForEach(viewModel.newReleases) { series in
                            SeriesCard(series: series)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                
                // Top Rated section
                SectionHeader(title: "Top Rated")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Use data from ViewModel
                        ForEach(viewModel.topRated) { series in
                            SeriesCard(series: series)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .padding(.top)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        // Optional: Show loading indicator or error message
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        // Trigger fetch data when the view appears
        // .onAppear { 
        //     viewModel.fetchData() // Already called in init, uncomment if needed elsewhere
        // }
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
    // Use the colors defined in SharedKit
    let gradient = Gradient(colors: [Color.systemSecondaryBackground, Color.systemTertiaryBackground])

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
                .frame(width: 150, height: 220)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.7))
                )

            Text(series.title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 4)

            Text("\(series.genre) • \(series.episodeCount) episodes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 150)
    }
}

// New struct for the large featured card
struct FeaturedSeriesCard: View {
    let series: Series
    let gradient = Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.8)])
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder for the large image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemSecondaryBackground) // Use the color defined in SharedKit
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                )
            
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
                }
            }
            .padding()
        }
        .frame(height: 250)
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
} 