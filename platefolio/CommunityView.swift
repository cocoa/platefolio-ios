import SwiftUI
import SwiftData
import UIKit

struct CommunityView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("localUserId") private var localUserId: String = ""
    @State private var query: String = ""

    @Query(sort: \PlatePostEntity.createdAt, order: .reverse)
    private var posts: [PlatePostEntity]

    private var filtered: [PlatePostEntity] {
        let qCanon = PlateSanitizer.canonicalize(query.uppercased())
        guard !qCanon.isEmpty else { return posts }

        return posts.filter { post in
            post.plateCanonical.contains(qCanon) ||
            post.tags.contains(where: { PlateSanitizer.canonicalize($0.uppercased()).contains(qCanon) })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered, id: \.id) { post in
                    HStack(spacing: 12) {
                        if let data = post.imageData, let img = UIImage(data: data) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.2))
                                .frame(width: 64, height: 48)
                                .overlay(Image(systemName: "car").foregroundStyle(.secondary))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(post.plateDisplay).font(.headline)
                            if !post.tags.isEmpty {
                                Text(post.tags.joined(separator: " · "))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if post.ownerID == localUserId {
                            Button(role: .destructive) {
                                modelContext.delete(post)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Community")
            .searchable(text: $query, prompt: "Search plate or tag")
        }
    }
}
