import SwiftUI
import SharedKit

struct FeedActionButtons: View {
    let item: FeedItem
    @Binding var isLiked: Bool
    @Binding var isSaved: Bool
    var onLike: () -> Void
    var onSave: () -> Void
    var onEpisodes: () -> Void
    var onShare: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Like Button
            VStack(spacing: 4) {
                Button(action: onLike) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .imageScale(.large)
                        .foregroundColor(isLiked ? .red : .white)
                }
                Text("\(item.formattedViewCount)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            // Save Button
            VStack(spacing: 4) {
                Button(action: onSave) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .imageScale(.large)
                        .foregroundColor(isSaved ? Color(hex: "9B79C1") : .white)
                }
                Text("Save")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            // Episodes Button
            VStack(spacing: 4) {
                Button(action: onEpisodes) {
                    Image(systemName: "list.bullet")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                Text("Episodes")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            
            // Share Button
            VStack(spacing: 4) {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                Text("Share")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 16)
    }
} 