//
//  HomeViewModel.swift
//  App
//

import Foundation
import SwiftUI // Needed for ObservableObject

// Basic placeholder model for a Series
// Conforming to Identifiable for ForEach loops
struct Series: Identifiable {
    let id = UUID()
    let title: String
    let description: String? // Optional for featured
    let genre: String
    let episodeCount: Int
    let thumbnailURL: URL? // Placeholder for image loading later
}

@MainActor // Ensure UI updates happen on the main thread
class HomeViewModel: ObservableObject {

    @Published var featuredSeries: [Series] = []
    @Published var newReleases: [Series] = []
    @Published var topRated: [Series] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    init() {
        // Initialize with placeholder data or call fetchData directly
        fetchData()
    }

    // Placeholder function for fetching data
    // In a real app, this would involve async network calls
    func fetchData() {
        isLoading = true
        errorMessage = nil

        // Simulate network delay and data loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            // Populate with placeholder data
            self.featuredSeries = [
                Series(title: "Featured Series 1", description: "A captivating tale.", genre: "Drama", episodeCount: 10, thumbnailURL: nil),
                Series(title: "Featured Series 2", description: "Another exciting story.", genre: "Sci-Fi", episodeCount: 8, thumbnailURL: nil),
                Series(title: "Featured Series 3", description: "Mystery unfolds.", genre: "Mystery", episodeCount: 12, thumbnailURL: nil)
            ]

            self.newReleases = [
                Series(title: "New Release A", description: nil, genre: "Comedy", episodeCount: 6, thumbnailURL: nil),
                Series(title: "New Release B", description: nil, genre: "Action", episodeCount: 9, thumbnailURL: nil),
                Series(title: "New Release C", description: nil, genre: "Romance", episodeCount: 7, thumbnailURL: nil),
                Series(title: "New Release D", description: nil, genre: "Thriller", episodeCount: 11, thumbnailURL: nil),
                Series(title: "New Release E", description: nil, genre: "Fantasy", episodeCount: 5, thumbnailURL: nil)
            ]

            self.topRated = [
                Series(title: "Top Rated X", description: nil, genre: "Adventure", episodeCount: 15, thumbnailURL: nil),
                Series(title: "Top Rated Y", description: nil, genre: "Horror", episodeCount: 8, thumbnailURL: nil),
                Series(title: "Top Rated Z", description: nil, genre: "Historical", episodeCount: 10, thumbnailURL: nil),
                Series(title: "Top Rated W", description: nil, genre: "Documentary", episodeCount: 4, thumbnailURL: nil),
            ]

            self.isLoading = false
        }
        
        // TODO: Add error handling simulation if needed
        // Uncomment below to simulate an error
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            self?.errorMessage = "Failed to load series data. Please try again."
            // Clear data on error? Or keep stale data? Decide based on UX needs.
            self?.featuredSeries = []
            self?.newReleases = []
            self?.topRated = []
        }
        */
    }
} 