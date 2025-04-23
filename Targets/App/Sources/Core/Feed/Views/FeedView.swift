import SwiftUI
import SharedKit
import VideoPlayerKit
import SupabaseKit
import AVKit

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var scrollIndex: Int = 0
    
    init(db: DB, seriesId: UUID, startingEpisode: Int = 1) {
        print("Initializing FeedView with seriesId: \(seriesId), startingEpisode: \(startingEpisode)")
        _viewModel = StateObject(wrappedValue: FeedViewModel(db: db, seriesId: seriesId, startingEpisode: startingEpisode))
        
        // Make Navigation Bar transparent
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear // Ensure no color tint
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance // For large titles
        UINavigationBar.appearance().compactAppearance = appearance // For inline titles
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button("Go Back") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "9B79C1"))
                        .cornerRadius(8)
                    }
                } else if !viewModel.feedItems.isEmpty {
                    ScrollViewReader { proxy in
                        feedScrollView(size: geometry.size, safeArea: geometry.safeAreaInsets)
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onEnded { gesture in
                                        // If swipe direction is mostly downward, dismiss
                                        if gesture.translation.height > 100 && 
                                           abs(gesture.translation.height) > abs(gesture.translation.width) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                            )
                            .onAppear {
                                print("FeedView ScrollViewReader onAppear. Items: \(viewModel.feedItems.count), Index: \(viewModel.currentIndex)")
                                if !viewModel.feedItems.isEmpty && viewModel.currentIndex > 0 && viewModel.currentIndex < viewModel.feedItems.count {
                                    let targetId = viewModel.feedItems[viewModel.currentIndex].id
                                    print("Attempting to scroll to ID: \(targetId) at index: \(viewModel.currentIndex)")
                                    proxy.scrollTo(targetId, anchor: .center)
                                }
                            }
                    }
                } else {
                    Text("No episodes available")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .toolbar(.hidden, for: .tabBar) // Keep tab bar hidden
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true) // Hide default back button
        .navigationBarItems(leading:
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
        )
        .onAppear {
            print("FeedView ZStack onAppear with \(viewModel.feedItems.count) items, initial index: \(viewModel.currentIndex)")
            
            // Ensure navbar appearance is set (might be needed if navigating back and forth)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }
        .onDisappear {
            // Optional: Restore default navbar appearance if needed elsewhere
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        }
    }
    
    @ViewBuilder
    private func feedScrollView(size: CGSize, safeArea: EdgeInsets) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.feedItems.indices, id: \.self) { index in
                    let item = viewModel.feedItems[index]
                    FeedPlayerCell(
                        item: item, 
                        size: size, 
                        safeArea: safeArea
                    )
                    .id(item.id)
                    .containerRelativeFrame(.vertical)
                    .onAppear {
                        viewModel.currentIndex = index
                        print("FeedView showing cell for episode \(item.episodeNumber), index: \(index)")
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
    }
}

// MARK: - Preference Key for Scroll Position
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Preview Provider
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        // Use mock DB for preview
        let mockDB = DB()
        // Use a mock UUID for preview
        let mockSeriesId = UUID()
        
        FeedView(db: mockDB, seriesId: mockSeriesId)
            .previewDisplayName("Feed View - Full Screen")
            .previewDevice("iPhone 14 Pro")
    }
} 
