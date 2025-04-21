//
//  LibraryView.swift
//  App
//

import SwiftUI
import SharedKit

struct LibraryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Continue Watching section
                    if !continueWatchingSeries.isEmpty {
                        SectionHeader(title: "Continue Watching")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(continueWatchingSeries) { series in
                                    ContinueWatchingCard(series: series)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // My Series section
                    SectionHeader(title: "My Series")
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 15)
                    ], spacing: 20) {
                        ForEach(savedSeries) { series in
                            SeriesLibraryCard(series: series)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Library")
        }
    }
    
    // Sample data
    var continueWatchingSeries: [SeriesItem] {
        [
            SeriesItem(id: "1", title: "The Last Hope", episodes: 12, progress: 0.3),
            SeriesItem(id: "2", title: "Dark Waters", episodes: 8, progress: 0.7),
            SeriesItem(id: "3", title: "City Lights", episodes: 10, progress: 0.1)
        ]
    }
    
    var savedSeries: [SeriesItem] {
        [
            SeriesItem(id: "1", title: "The Last Hope", episodes: 12, progress: 0.3),
            SeriesItem(id: "2", title: "Dark Waters", episodes: 8, progress: 0.7),
            SeriesItem(id: "3", title: "City Lights", episodes: 10, progress: 0.1),
            SeriesItem(id: "4", title: "Broken Promises", episodes: 15, progress: 0.5),
            SeriesItem(id: "5", title: "New Dawn", episodes: 6, progress: 0)
        ]
    }
}

struct SeriesItem: Identifiable {
    let id: String
    let title: String
    let episodes: Int
    let progress: Double // 0.0 to 1.0
}

struct ContinueWatchingCard: View {
    let series: SeriesItem
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 250, height: 140)
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                
                // Progress bar
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * series.progress, height: 4)
                }
                .frame(height: 4)
            }
            
            Text(series.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("\(Int(series.progress * 100))% complete • \(series.episodes) episodes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 250)
    }
}

struct SeriesLibraryCard: View {
    let series: SeriesItem
    
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 220)
                .overlay(
                    VStack {
                        Spacer()
                        // Progress indicator
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(height: 4)
                                
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * series.progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                )
            
            Text(series.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("\(Int(series.progress * 100))% • \(series.episodes) episodes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LibraryView()
} 