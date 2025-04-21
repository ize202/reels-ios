//
//  HomeView.swift
//  App
//

import SwiftUI
import SharedKit

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Trending section
                    SectionHeader(title: "Trending")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                SeriesCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // New Releases section
                    SectionHeader(title: "New Releases")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                SeriesCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Top Rated section
                    SectionHeader(title: "Top Rated")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                SeriesCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
    }
}

struct SeriesCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 220)
                .overlay(
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )
            
            Text("Series Title")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("Drama • 8 episodes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 150)
    }
}

#Preview {
    HomeView()
} 