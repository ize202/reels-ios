//
//  LibraryViewModel.swift
//  App
//

import Foundation
import SwiftUI

// --- Data Models ---

// Represents a series the user is currently watching
struct WatchedSeries: Identifiable {
    let id = UUID()
    let seriesId: String // Link to the actual series data
    let title: String
    let lastWatchedEpisode: Int
    let totalEpisodes: Int
    let thumbnailURL: URL? // Placeholder
    
    var progressString: String {
        "EP.\(lastWatchedEpisode)"
    }
}

// Represents a series saved by the user
struct SavedSeries: Identifiable {
    let id = UUID()
    let seriesId: String // Link to the actual series data
    let title: String
    let totalEpisodes: Int
    let thumbnailURL: URL? // Placeholder
    
    var episodesString: String {
        "All \(totalEpisodes) EP"
    }
}

// --- ViewModel ---

@MainActor
class LibraryViewModel: ObservableObject {
    
    @Published var recentlyWatched: [WatchedSeries] = []
    @Published var savedCollection: [SavedSeries] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init() {
        fetchLibraryData()
    }
    
    func fetchLibraryData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate fetching data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            
            self.recentlyWatched = [
                WatchedSeries(seriesId: "1", title: "Divorced Housewife Billionaire Heiress", lastWatchedEpisode: 3, totalEpisodes: 70, thumbnailURL: nil),
                WatchedSeries(seriesId: "2", title: "True Love Waits", lastWatchedEpisode: 15, totalEpisodes: 70, thumbnailURL: nil),
                WatchedSeries(seriesId: "3", title: "Captive Love from the Mob Boss", lastWatchedEpisode: 1, totalEpisodes: 65, thumbnailURL: nil),
                WatchedSeries(seriesId: "4", title: "I Don't Know My Husband is a Billionaire", lastWatchedEpisode: 2, totalEpisodes: 80, thumbnailURL: nil)
            ]
            
            self.savedCollection = [
                SavedSeries(seriesId: "2", title: "True Love Waits", totalEpisodes: 70, thumbnailURL: nil),
                SavedSeries(seriesId: "5", title: "Modern Journey of an Ancient Queen", totalEpisodes: 75, thumbnailURL: nil),
                SavedSeries(seriesId: "6", title: "Bound To The Tyrant's Heart", totalEpisodes: 62, thumbnailURL: nil),
                SavedSeries(seriesId: "7", title: "I Peaked After the Breakup", totalEpisodes: 65, thumbnailURL: nil),
                SavedSeries(seriesId: "3", title: "Captive Love from the Mob Boss", totalEpisodes: 65, thumbnailURL: nil),
                SavedSeries(seriesId: "8", title: "Love at Fifty", totalEpisodes: 62, thumbnailURL: nil)
            ]
            
            self.isLoading = false
        }
    }
} 