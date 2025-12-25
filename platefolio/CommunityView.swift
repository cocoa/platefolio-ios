import SwiftUI

struct CommunityView: View {
    @StateObject private var store = PlateStoreHolder.shared.store
    @State private var query: String = ""

    var filtered: [PlatePost] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let qCanonical = PlateSanitizer.canonicalize(q)

        guard !q.isEmpty else { return store.community }

        return store.community.filter { post in
            post.plateCanonical.contains(qCanonical) ||
            post.tags.contains(where: {
                PlateSanitizer.canonicalize($0.uppercased()).contains(qCanonical)
            })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { post in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(post.plateDisplay).font(.headline)
                        if !post.tags.isEmpty {
                            Text(post.tags.joined(separator: " · "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Search plates or tags")
            .navigationTitle("Community")
        }
    }
}
